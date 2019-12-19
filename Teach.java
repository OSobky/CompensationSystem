
public class Teach {
	String instructor;
	String subject;
	String tutNum;
	String groupName;
	int type;
	int groupNum;
	int firstYear;
	int hall;
	int slot;
	
	public Teach( int type, String instructor, int groupNum, String tutNum, String groupName, int firstYear, String subject, int hall, int slot ) {
		this.type = type;
		this.instructor = instructor;
		this.groupNum = groupNum;
		this.tutNum = tutNum;
		this.groupName = groupName;
		this.firstYear = firstYear;
		this.subject = subject;
		this.hall = hall;
		this.slot = slot;
	}
	
	public String toString() {
		String fact = "teach(";
		fact += type + ",";
		fact += "'" + instructor + "',";
		fact += groupNum + ",";
		fact += tutNum + ",";
		fact += "'" + groupName + "',";		
		fact += firstYear + ",";		 
		fact += "'" + subject + "',";
		fact += hall + ",";
		fact += slot;
		fact += ").\n";
		
		return fact;
	}
}
