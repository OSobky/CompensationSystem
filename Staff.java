import java.util.ArrayList;

public class Staff {
	String name;
	ArrayList<Integer> occSlots = new ArrayList<Integer>();
	ArrayList<Integer> daysOff = new ArrayList<Integer>();
	
	public Staff( String name ) {
		this.name = name;
	}
	
	public Staff( String name, ArrayList<Integer> daysOff) {
		this.name = name;
		this.daysOff.addAll(daysOff);
	}
	
	public void addSlot( int slot ) {
		if( !occSlots.contains(slot) ) 
			occSlots.add(slot);
	}
	
	public String toString() {
		String fact = "staff('";
		fact += name + "',[";
		
		for( int i = 0; i < occSlots.size(); i++ ) {
			fact += occSlots.get(i) + ",";
		}
		
		fact = fact.substring(0,fact.length()-1);
		fact += "]";
		
		if( daysOff.size() > 0 ) {
			fact += ",[";
			for( int i = 0; i < daysOff.size(); i++ ) {
				fact += daysOff.get(i) + ",";
			}
			
			fact = fact.substring(0,fact.length()-1);
			fact += "]";
		} else {
			fact += ",_";
		}
		
		fact +=	").\n";
		
		return fact;
	}

}
