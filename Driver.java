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
