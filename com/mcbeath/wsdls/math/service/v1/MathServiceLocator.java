/**
 * MathServiceLocator.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis WSDL2Java emitter.
 */

package com.mcbeath.wsdls.math.service.v1;

public class MathServiceLocator extends org.apache.axis.client.Service implements com.mcbeath.wsdls.math.service.v1.MathService {

    // Use to get a proxy class for MathPort
    private final java.lang.String MathPort_address = "http://localhost:8007/SOAPRouter.xqy";

    public java.lang.String getMathPortAddress() {
        return MathPort_address;
    }

    // The WSDD service name defaults to the port name.
    private java.lang.String MathPortWSDDServiceName = "MathPort";

    public java.lang.String getMathPortWSDDServiceName() {
        return MathPortWSDDServiceName;
    }

    public void setMathPortWSDDServiceName(java.lang.String name) {
        MathPortWSDDServiceName = name;
    }

    public com.mcbeath.bindings.math.service.v1.MathServicePortType getMathPort() throws javax.xml.rpc.ServiceException {
       java.net.URL endpoint;
        try {
            endpoint = new java.net.URL(MathPort_address);
        }
        catch (java.net.MalformedURLException e) {
            throw new javax.xml.rpc.ServiceException(e);
        }
        return getMathPort(endpoint);
    }

    public com.mcbeath.bindings.math.service.v1.MathServicePortType getMathPort(java.net.URL portAddress) throws javax.xml.rpc.ServiceException {
        try {
            com.mcbeath.bindings.math.service.v1.MathServiceSoapBindingStub _stub = new com.mcbeath.bindings.math.service.v1.MathServiceSoapBindingStub(portAddress, this);
            _stub.setPortName(getMathPortWSDDServiceName());
            return _stub;
        }
        catch (org.apache.axis.AxisFault e) {
            return null;
        }
    }

    /**
     * For the given interface, get the stub implementation.
     * If this service has no port for the given interface,
     * then ServiceException is thrown.
     */
    public java.rmi.Remote getPort(Class serviceEndpointInterface) throws javax.xml.rpc.ServiceException {
        try {
            if (com.mcbeath.bindings.math.service.v1.MathServicePortType.class.isAssignableFrom(serviceEndpointInterface)) {
                com.mcbeath.bindings.math.service.v1.MathServiceSoapBindingStub _stub = new com.mcbeath.bindings.math.service.v1.MathServiceSoapBindingStub(new java.net.URL(MathPort_address), this);
                _stub.setPortName(getMathPortWSDDServiceName());
                return _stub;
            }
        }
        catch (java.lang.Throwable t) {
            throw new javax.xml.rpc.ServiceException(t);
        }
        throw new javax.xml.rpc.ServiceException("There is no stub implementation for the interface:  " + (serviceEndpointInterface == null ? "null" : serviceEndpointInterface.getName()));
    }

    /**
     * For the given interface, get the stub implementation.
     * If this service has no port for the given interface,
     * then ServiceException is thrown.
     */
    public java.rmi.Remote getPort(javax.xml.namespace.QName portName, Class serviceEndpointInterface) throws javax.xml.rpc.ServiceException {
        if (portName == null) {
            return getPort(serviceEndpointInterface);
        }
        String inputPortName = portName.getLocalPart();
        if ("MathPort".equals(inputPortName)) {
            return getMathPort();
        }
        else  {
            java.rmi.Remote _stub = getPort(serviceEndpointInterface);
            ((org.apache.axis.client.Stub) _stub).setPortName(portName);
            return _stub;
        }
    }

    public javax.xml.namespace.QName getServiceName() {
        return new javax.xml.namespace.QName("http://wsdls.mcbeath.com/math/service/v1/", "MathService");
    }

    private java.util.HashSet ports = null;

    public java.util.Iterator getPorts() {
        if (ports == null) {
            ports = new java.util.HashSet();
            ports.add(new javax.xml.namespace.QName("MathPort"));
        }
        return ports.iterator();
    }

}
