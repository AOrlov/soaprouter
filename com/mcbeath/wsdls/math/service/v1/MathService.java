/**
 * MathService.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis WSDL2Java emitter.
 */

package com.mcbeath.wsdls.math.service.v1;

public interface MathService extends javax.xml.rpc.Service {
    public java.lang.String getMathPortAddress();

    public com.mcbeath.bindings.math.service.v1.MathServicePortType getMathPort() throws javax.xml.rpc.ServiceException;

    public com.mcbeath.bindings.math.service.v1.MathServicePortType getMathPort(java.net.URL portAddress) throws javax.xml.rpc.ServiceException;
}
