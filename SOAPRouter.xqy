(:-------------------------------------------------------------

Script: SOAP Router

Version: 0.1

Author: Darin McBeath

Date:   September 22, 2004

This script serves the following role:

  1. Accepts requests in SOAP Wrapped Document Literal format.	
  2. Processes the SOAP request to extract the targeted
     operation to invoke (a user defined xquery function).
  3. Finds the location of the library module.
  4. Finds the database to use for execution of the query.
  5. Invokes the function (with the extracted parameters).
  6. Constructs a SOAP Wrapped Document Literal response
     containing the results of the function.

Notes:

* No support for SOAP Headers or SOAP Header Faults.
* No support for SOAP with Attachments.
* Requests MUST BE in wrapped document literal format.
  http://www-106.ibm.com/developerworks/webservices/library/ws-whichwsdl
* This SOAP implementation is not 100% WS-I compliant.

-------------------------------------------------------------:)

(:-----------------------------------------------------------:)
(: Various Namespace Declarations                            :)
(:-----------------------------------------------------------:)
declare namespace soapenv="http://schemas.xmlsoap.org/soap/envelope/"
declare namespace xsd="http://www.w3.org/2001/XMLSchema"
declare namespace xsi="http://www.w3.org/2001/XMLSchema-instance"
default function namespace="http://www.w3.org/2003/05/xpath-functions"

(:-----------------------------------------------------------:)
(: FUNCTION --> Process the SOAP message                     :)
(:                                                           :)
(: Since Mark Logic does not support the validate expression :)
(: this function attempts to enforce the integrity of the    :)
(: SOAP message structure and to extract the 'method         :)
(: wrapper' which will be used to invoke the related         :)
(: function defined in a library module.                     :)
(:                                                           :)
(: Input    The HTTP POST body                               :)
(:                                                           :)
(: Output   The method wrapper element                       :)
(:-----------------------------------------------------------:)
define function process-message($msg as xs:string?)
       as element()? {

  (: Ensure that a post body message was received :)

  if (empty($msg)) then

    error("001",
          ("HTTPFault",
           "HTTP-There is no SOAP Envelope"))
  else

    (: Parse the post body :)

    let $parsed    := xdmp:unquote($msg)
    return

      (:Ensure the root is of type Envelope for SOAP Version 1.1 :)

      if (not($parsed instance of element(soapenv:Envelope,*))) then

        error("002",
              ("HTTPFault",
               "HTTP-Root is not of type SOAP Envelope 1.1"))

      (: There can be only 1 or 2 descendant elements for SOAP Envelope.  :)
      (: If there is one, it can only be of type Body.  If there are two, :)
      (: the first must be of type Header and the second must be of type  :)
      (: Body.  In addition, a Body must have exactly one child element.  :)

      else if (count($parsed/element()) = 1) then

        if (not($parsed/element() instance of element(soapenv:Body,*))) then

          error("003",
                ("SOAPFault",
                 "SOAPClient",
                 "SOAP-Body is not immediate descendant of Envelope")) 
                 
        else if (count($parsed/soapenv:Body/element()) > 1) then

          error("004",
                ("SOAPFault",
                 "SOAPClient",
                 "SOAP-More than 1 elements are children of Body"))

        else

          $parsed/soapenv:Body/element()

      else if (count($parsed/element()) = 2) then

        if (not($parsed/element()[1] instance of element(soapenv:Header,*))) then

          error("005",
                ("SOAPFault",
                 "SOAPClient",
                 "SOAP-Misplaced Header element"))

        else if (not($parsed/element()[2] instance of element(soapenv:Body,*))) then

          error("006",
                ("SOAPFault",
                 "SOAPClient",
                 "SOAP-Misplaced Body element"))

        else if (count($parsed/soapenv:Body/element()) > 1) then        

          error("004",
                ("SOAPFault",
                 "SOAPClient",
                 "SOAP-More than 1 elements are children of Body"))

        else

            $parsed/soapenv:Body/element()

      else

        error()
 
}

(:-----------------------------------------------------------:)
(: FUNCTION --> Find the Database                            :)
(:                                                           :)
(: Input    The operation URI                                :)
(:          The operation name                               :)
(:                                                           :)
(: Output   The database identifier                          :)                                                          
(:-----------------------------------------------------------:)
define function find-database($methodUri as xs:string,
                              $methodName as xs:string)

       as xs:unsignedLong {

  let $db := doc("soap-deployment-descriptor")//entry
                [namespace-uri = $methodUri]
                [method-name = $methodName]
  return

    if (empty($db)) then

      error("007",
            ("SOAPFault",
             "SOAPClient",
             "SOAP-Unknown operation specified"))

    else

      let $dbno := xdmp:database(xs:string($db/database))
      return

        if (empty($dbno)) then

          error("100",
                ("SOAPFault",
                 "SOAPServer",
                 "SOAP-Unknown database"))
        else

          $dbno 

}

(:-----------------------------------------------------------:)
(: FUNCTION --> Find the Library Module                      :)
(:                                                           :)
(: Input    The operation URI                                :)
(:          The operation name                               :)
(:                                                           :)
(: Output   The library module location                      :)                                                          
(:-----------------------------------------------------------:)
define function find-library-module($methodUri as xs:string,
                                    $methodName as xs:string)

       as xs:string {

  let $db := doc("soap-deployment-descriptor")//entry
                [namespace-uri = $methodUri]
                [method-name = $methodName]
  return
    xs:string($db/module-location)

}

(:-----------------------------------------------------------:)
(: FUNCTION --> Construct the XQuery                         :)
(:                                                           :)
(: Input    The operation URI                                :)
(:          The operation name                               :)
(:          The library module location                      :)
(:          The operation parameters                         :)
(:                                                           :)
(: Output   The query to evaluate                            :)                                                          
(:-----------------------------------------------------------:)
define function construct-query($methodUri as xs:string,
                                $methodName as xs:string,
                                $libraryModule as xs:string,
                                $methodWrapper as element())
       as xs:string {
                      		      			                    		
   concat('import module "',
          $methodUri, 
          '" ',
          ' at "',
          $libraryModule,
          '" ',
          'declare namespace route="',
          $methodUri, 
          '" ',
          'route:',
          $methodName, 
          "(xs:string('",
          xdmp:quote($methodWrapper),                       
          "'))")

}


(:-----------------------------------------------------------:)
(: FUNCTION --> Evaluate the Query                           :)
(:                                                           :)  
(: Input    The query to evaluate                            :)
(:          The database to use                              :)
(:                                                           :)  
(: Output   Results of the query                             :)
(:-----------------------------------------------------------:)
define function evaluate-query($query as xs:string,
                               $db as xs:unsignedLong)
       as item()* {

  try {
    xdmp:log($query),
    xdmp:eval-in($query, $db)

  } catch ($exception) {
    xdmp:log($exception),
    error($exception,
          ("SOAPFault",
           "SOAPServer",
           "SOAP-",
           string-join(data($exception//*:datum),"--")))
          		
  }

}

(:-----------------------------------------------------------:)
(: FUNCTION --> Construct the successful SOAP response       :)
(:                                                           :)  
(: The results of the invoked operation are returned.  The   :)
(: root element for the response will adhere to wrapped      :)
(: document literal ... in other words, the root local name  :)
(: will be the operation name invoked with "Response"        :)
(: appended.  The Namespace for this element will be the     :)
(: same as the invoked operation.  An HTTP status code of    :)
(: 200 will be returned.                                     :)
(:                                                           :)
(: Input    The operation uri                                :)
(:          The operation name                               :)
(:          The results of the operation                     :)
(:                                                           :)  
(: Output   The SOAP Response                                :)  
(:-----------------------------------------------------------:)
define function construct-response($methodUri as xs:string,
                                   $methodName as xs:string,
                                   $result as item()* )
       as element() {

  ( xdmp:set-response-code(200,""),
    xdmp:set-response-content-type("text/xml"),
    <soapenv:Envelope>
    <soapenv:Body>
    { element  { expanded-QName($methodUri, concat($methodName,"Response")) }
      { $result }
    }
    </soapenv:Body>
    </soapenv:Envelope> )

}

(:-----------------------------------------------------------:)
(: FUNCTION --> Log an error record                          :)
(:                                                           :)  
(: Input    The error string                                 :)
(:                                                           :)  
(: Output   Empty                                            :)  
(:-----------------------------------------------------------:)
define function log-error($msg as xs:string?)                          
       as empty() {

  if (empty($msg)) then
    xdmp:log("Unknown Message")
  else
    xdmp:log($msg)

}

(:-----------------------------------------------------------:)
(: FUNCTION --> Generate a SOAP Body fault                   :)
(:                                                           :)
(: Find those dataum elements with a value beginning with    :)
(: 'SOAP-'.  This error message text would have been set     :)
(: by one of the above functions. Extract the text after     :)
(: this prefix and concatenate into the SOAP message to      :)
(: return.  An HTTP status code of 500 is returned.          :)
(:                                                           :)
(: Input    The Exception element                            :)
(:                                                           :)
(: Output   SOAP Body Fault                                  :)
(:-----------------------------------------------------------:)
define function soap-body-fault($error as element())
       as element() {

  let $msg :=  if ($error//*:datum = "SOAPFault") then

                for $i in data($error//*:datum)
                return
                  if (starts-with($i,"SOAP-")) then
                    substring-after($i,"SOAP-")
                  else
                    ()
              else

                concat("General Server Error - ",
                       data($error//*:code),
                       " - ",
                       data($error//*:msg))                       

  let $code := if ($error//*:datum = "SOAPClient") then
                 "soap:Client"
               else
                 "soap:Server"

  return

  ( log-error($msg),   
    xdmp:set-response-code(500,""),
    xdmp:set-response-content-type("text/xml"),   
    <soapenv:Envelope>
    <soapenv:Body>
    <soapenv:Fault>
    <faultcode>{$code}</faultcode>
    <faultstring>{$msg}</faultstring>
    <detail/>
    </soapenv:Fault>
    </soapenv:Body>
    </soapenv:Envelope> )

}

(:-----------------------------------------------------------:)
(: FUNCTION --> Generate a HTTP fault                        :)
(:                                                           :)
(: Find those dataum elements with a value beginning with    :)
(: 'HTTP-'.  This error message text would have been set     :)
(: by one of the above functions. Extract the text after     :)
(: this prefix and concatenate into the HTTP message to      :)
(: return. An HTTP status code of 400 is returned.           :)
(:                                                           :)
(: Input    The Exception element                            :)
(:                                                           :)
(: Output   Empty                                            :)
(:-----------------------------------------------------------:)
define function http-fault($error as element())
       as empty() {

  let $msg := for $i in data($error//*:datum)
              return
                  if (starts-with($i,"HTTP-")) then
                    substring-after($i,"HTTP-")
                  else
                    ()


  return

    ( log-error($msg), 
      xdmp:set-response-code(400, 
                             if (empty($msg)) then
                               "Unknown Error"
                             else
                               $msg ) )

}

(:-----------------------------------------------------------:)
(: MAINLINE                                                  :)
(:-----------------------------------------------------------:)

  try {

    let $methodWrapper := process-message(xdmp:get-request-body())

    let $methodUri := get-namespace-from-QName(node-name($methodWrapper))
    let $methodName := get-local-name-from-QName(node-name($methodWrapper))

    let $db := find-database($methodUri, $methodName)

    let $libraryModule := find-library-module($methodUri, $methodName)

    let $query := construct-query($methodUri, 
                                  $methodName, 
                                  $libraryModule, 
                                  $methodWrapper)
  
    let $result := evaluate-query($query, $db) 

    return

	construct-response($methodUri, $methodName, $result) 

  }  catch ($exception) {

    (: Interrogate the dataum elements defined in the Mark Logic    :)
    (: defined error element.  The various functions defined above  :)
    (: will invoke the error function (throw an exception) and will :)
    (: set values for the datum elements.  For example, if a HTTP   :)
    (: Fault sould be returned, a value of HTTPFault should be set  :)
    (: in a datum element.  Likewise, if a SOAP Fault should be     :)
    (: returned, a value of SOAPFault should be set in a dataum     :)
    (: element.  If neither value is set, the assumption is SOAP    :)
    (: Fault.                                                       :)

    if ($exception//*:datum = "HTTPFault") then

      http-fault($exception)

    else 

      soap-body-fault($exception)  

}





