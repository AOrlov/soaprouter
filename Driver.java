/*
 : Copyright (c) 2004 Mark Logic Corporation
 :
 : Licensed under the Apache License, Version 2.0 (the "License");
 : you may not use this file except in compliance with the License.
 : You may obtain a copy of the License at
 :
 : http://www.apache.org/licenses/LICENSE-2.0
 :
 : Unless required by applicable law or agreed to in writing, software
 : distributed under the License is distributed on an "AS IS" BASIS,
 : WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 : See the License for the specific language governing permissions and
 : limitations under the License.
 :
 : The use of the Apache License does not indicate that this project is
 : affiliated with the Apache Software Foundation.
 */

import com.mcbeath.bindings.math.service.v1.MathServicePortType;
import com.mcbeath.wsdls.math.service.v1.MathServiceLocator;
import com.mcbeath.types.math.service.v1.OperandType;
import org.apache.axis.client.Service;

public class Driver {

	public static void main(String[] args) {
		
			try {
				Service service = new MathServiceLocator();
				MathServicePortType port = (MathServicePortType) service.getPort(MathServicePortType.class);
				OperandType operand1 = new OperandType("1");
				OperandType operand2 = new OperandType("2");
				System.out.println(port.addition(operand1, operand2));
			} catch (Exception ex) {
				System.out.println(ex.toString());
			}	
	}
	
}
