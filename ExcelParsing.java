import java.io.File;  
import java.io.FileInputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Iterator;  
import org.apache.poi.ss.usermodel.Cell;  
import org.apache.poi.ss.usermodel.Row;  
import org.apache.poi.xssf.usermodel.XSSFSheet;  
import org.apache.poi.xssf.usermodel.XSSFWorkbook;   

public class ExcelParsing {

	public static void main(String[]args) throws IOException {
		String currentFolder = System.getProperty("user.dir");
		String filePath = currentFolder + "\\modifiedSchedule2.xlsx";
		File file = new File(filePath); 
		FileInputStream modifiedSchedule = new FileInputStream(file);
		XSSFWorkbook wb = new XSSFWorkbook(modifiedSchedule);
		
		ArrayList<Teach> KB = new ArrayList<Teach>();
		
		for( int i = 0; i < 6; i++ ) {
			XSSFSheet sheet = wb.getSheetAt(i);
			ArrayList<Teach> dayKB = parseSchedule(sheet, i);
			KB.addAll(dayKB);
		}
		
		wb.close();
		
		String KBStr = "";
		for( int i = 0; i < KB.size(); i++ ) {
			KBStr += KB.get(i).toString();
		}
		
		ArrayList<Staff> members = getStaffMembers(KB); 
		for( int i = 0; i < members.size(); i++ ) {
			if( !members.get(i).name.equals("_") ) {
				members.get(i).genDaysOff();
				KBStr += members.get(i).toString();
			}
		}
		
		KBStr += "ava(5,1,50,8).";
		KBStr = KBStr.trim();
		
		String KBDest = "../../Repo/KB.pl";
		PrintWriter writer = new PrintWriter(KBDest, "UTF-8");
		writer.println(KBStr);
		writer.close();
		
	}
	
	public static ArrayList<Teach> parseSchedule( XSSFSheet sheet, int day ) throws IOException {
		Iterator<Row> itr = sheet.iterator();
		ArrayList<Teach> KB = new ArrayList<Teach>();
		int offset = 5 * day;
		
		while (itr.hasNext()) {  
			Row row = itr.next();  
			Iterator<Cell> cellIterator = row.cellIterator(); 
			
			String currentGroup = "";
			String[] tutsInGroup = null;
			int slot = 0;
			
			while (cellIterator.hasNext()) {
				Cell cell = cellIterator.next();
				String value = cell.getStringCellValue();
				
				if( value.equals("") ) 
					continue;
				
				if( slot == 0 ) {
					currentGroup = filterGroupName(value);
					tutsInGroup = extractTutsInGroup(value);
				} else {
					if( currentGroup.charAt(0) != '1' ) 
						continue;
					
					int firstYear = isFirstYear(currentGroup);
					int groupNum = extractGroupNumber(currentGroup);
					int hall = lectureHall(value);
					int type = teachType(value);
					int weekSlot = slot + offset;
										
					String[] instructors = extractInstructors(value);
					String[] subjectName = extractSubjectName(value);
					
					if( type == 3 ) {
						ArrayList<Teach> freeFacts = createFreeFacts(tutsInGroup, groupNum, currentGroup, firstYear, weekSlot);
						for( int i = 0; i < freeFacts.size(); i++ ) {
							String factTut = freeFacts.get(i).tutNum;
							boolean found = true;
							for( int j = 0; j < KB.size(); j++ ) {
								Teach currentFact = KB.get(j);
								boolean match = currentFact.groupName.equals(currentGroup) && 
												currentFact.tutNum.equals(factTut) &&
												currentFact.groupNum == groupNum &&
												currentFact.firstYear == firstYear &&
												currentFact.slot == weekSlot;
								
								found = found && !match;
							}
							if( found ) 
								KB.add(freeFacts.get(i));
						}
					}
					
					else if( hall != 0 ) {
						for( int i = 0; i < instructors.length; i++ ) {
							String instructor = instructors[i];
							String subject = subjectName[i];
							
							ArrayList<Teach> facts = createLecturesFacts(type, instructor, groupNum, tutsInGroup, currentGroup, firstYear, subject, hall, weekSlot);
							KB.addAll(facts);
							
						}
					} else {
						String[] subjectAndTuts = extractSubjectAndTuts(value, tutsInGroup);
						for( int i = 0; i < instructors.length; i++ ) {
							String instructor = instructors[i];
							String tutorial = subjectAndTuts[i+1];
							Teach fact = new Teach(type, instructor, groupNum, tutorial, currentGroup, firstYear, subjectAndTuts[0], hall, weekSlot);
							KB.add(fact);
						}
					}
				}
				slot++;
			}
		}
		return KB;
	}
	
	public static ArrayList<Staff> getStaffMembers( ArrayList<Teach> KB ) {
		ArrayList<Staff> staffMembers = new ArrayList<Staff>();
		for( int i = 0; i < KB.size(); i++ ) {
			String staffMember = KB.get(i).instructor;
			boolean found = false;
			int staffPos = 0;
			
			for( int j = 0; j < staffMembers.size() && !found; j++ ) {
				if( staffMembers.get(j).name.equals(staffMember) ) {
					found  = true;
					staffPos = j;
				}
			}
			
			if( found )
				staffMembers.get(staffPos).addSlot(KB.get(i).slot);
			else {
				Staff member = new Staff(staffMember);
				member.addSlot(KB.get(i).slot);
				staffMembers.add(member);
			}
		}
		return staffMembers;
	}
	
	public static void printArray( String[] arr ) {
		for (int i = 0; i < arr.length; i++) {
			System.out.println(arr[i]);
		}
	}
	
	public static String [] extractInstructors( String subject ) {
		String [] instructors;
		String instructor = "";
		boolean found = false;
		
//		Extracts The String Between The Brackets
		for( int i = 0; i < subject.length(); i++ ) {
			if( subject.charAt(i) == '(' ) 
				found = true;
			else if ( found ) {
				if( subject.charAt(i) == ')' )
					found = false;
				else 
					instructor += subject.charAt(i);
			}
		}
		
//		If There Is Multiple Instructors We Need To Split Them
		if( instructor.contains(",") ) 
			instructors = instructor.split(",");
//		If Only One Exists We Return An Array Of Size One With The Instructor's Name
		else {
			instructors = new String[1];
			instructors[0] = instructor;
		}
		
		for( int i = 0; i < instructors.length; i++ ) {
			instructors[i] = instructors[i].trim();
		}
		
		return instructors;
	}
	
	public static String [] extractTutsInGroup( String groupName ) {
		String tuts = "";
		for( int i = groupName.length()-1; i > 0; i-- ) {
			if( groupName.charAt(i) == '(' )
				break;
			if( groupName.charAt(i) != ')' ) 
				tuts = groupName.charAt(i) + tuts;
		}
		return tuts.split("-");
	}
	
	public static String [] extractSubjectAndTuts( String subject, String[] tutsInGroup ) {
		
		boolean AE = subject.contains(" AE");
		boolean EN = subject.contains(" EN");
		boolean DE = subject.contains(" DE");
		boolean TUT = subject.contains("2 Tut") || subject.contains("1 Tut");
	
		if( Character.isDigit(subject.charAt(0)) ) {
			int tutCount = Integer.parseInt("" + subject.charAt(0));
			
			if( Character.isDigit(subject.charAt(1)) ) 
				tutCount = Integer.parseInt("" + subject.charAt(0) + subject.charAt(1));
			
			if( TUT ) {
				tutCount = Integer.parseInt(tutsInGroup[1]) - Integer.parseInt(tutsInGroup[0]);
			}
			
			String[] subjectAndTuts = new String[tutCount + 1];
			
			if( AE )
				subjectAndTuts[0] = "AE";
			else if ( DE )
				subjectAndTuts[0] = "DE";
			else if ( TUT )
				subjectAndTuts[0] = tutCount + " TUT";
			else if ( EN )
				subjectAndTuts[0] = "EN";
			
			int startTut = Integer.parseInt(tutsInGroup[0]);
			for( int i = 0; i < tutCount; i++ ) {
				subjectAndTuts[i+1] = "" + (startTut + i);
			}
			
			return subjectAndTuts;
			
		}
		
		
		String subjectName = "";
		String tutGroups = "";
		
		boolean endSubject = false;
		boolean endTutorials = false;
		
		for( int i = 0; i < subject.length() && !endTutorials; i++ ) {
			if( subject.charAt(i) == ' ' && Character.isDigit(subject.charAt(i+1)) ) {
				endSubject = true;
				continue;
			}
			else if( !endSubject )
				subjectName += subject.charAt(i);
			
			if( subject.charAt(i) == '(' ) 
				endTutorials = true;
			else if( !endTutorials && endSubject )
				tutGroups += subject.charAt(i);	
		}
		
		String[] tuts = tutGroups.split(",");
		String[] subjectAndTuts = new String[tuts.length + 1];
		
		for (int i = 0; i < tuts.length; i++) {
			tuts[i] = tuts[i].trim();
		}
		
		subjectAndTuts[0] = subjectName;
		for( int i = 1; i < subjectAndTuts.length; i++ ) {
			subjectAndTuts[i] = tuts[i-1];
		}
		
		return subjectAndTuts;
	}

	public static String [] extractSubjectName( String subject ) {
		String subjectName = "";
		for( int i = 0; i < subject.length(); i++ ) {
			if( subject.charAt(i) == '(' )
				break;
			subjectName += subject.charAt(i);
		}
		
		if( subjectName.contains("/") ) {
			String[] subjects = subjectName.split("/");
			for (int i = 0; i < subjects.length; i++) {
				subjects[i] = subjects[i].trim();
			}
			return subjects;
		}
		else {
			String [] subjects = new String[1];
			subjects[0] = subjectName.trim();
			return subjects;
		}
	}
	
	public static int extractGroupNumber( String groupName ) {
		String[] romanNumbers = {"I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"};
		String romanNumber = "";
		
//		Extracts The Roman Number From The String
		for( int i = groupName.length()-1; i > 0; i-- ) {
			if( groupName.charAt(i) == ' ' ) 
				break;
			romanNumber = groupName.charAt(i) + romanNumber;
		}
		
//		Finds A Match With The List Of Roman Numbers
		for( int i = 0; i < romanNumbers.length; i++ ) {
			if( romanNumber.equals(romanNumbers[i]) ) {
				return i+1;
			}
		}
		return 1;
	}

	public static String filterGroupName( String groupName ) {
		int spacePos = -1;
		for( int i = groupName.length()-1; i > 0; i-- ) {
			if( groupName.charAt(i) == ' ' ) {
				spacePos = i;
				break;
			}
		}
		
		return groupName.substring(0,spacePos);
	}

	public static int isFirstYear( String groupName ) {
		if( groupName.charAt(0) == '1' )
			return 1;
		return 0;
	}
	
	public static int lectureHall( String subject ) {
		for( int i = 19; i > 0; i-- ) {
			String hall = "H"+i;
			if( subject.contains(hall) )
				return i;
		}
		return 0;
	}
	
	public static int teachType( String subject ) {
		if( subject.equals("FREE") )
			return 3;
		if( subject.contains("lab") || subject.contains("Lab") )
			return 2;
		
		int hall = lectureHall(subject);
		if( hall > 0 || subject.contains("(room)") )
			return 0;
		
		return 1;
	}
	
	public static String createFact( int type, String instructor, int groupNum, String tutNum, String groupName, int firstYear, String subject, int hall, int slot) {	
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

	public static ArrayList<Teach> createLecturesFacts( int type, String instructor, int groupNum, String[] tutsInGroup, String groupName, int firstYear, String subject, int hall, int slot) {
		ArrayList<Teach> facts = new ArrayList<Teach>();
		int startTut = Integer.parseInt(tutsInGroup[0]);
		int endTut = Integer.parseInt(tutsInGroup[1]);
		
		for( int i = startTut; i <= endTut; i++ ) {
			String tutNum = "" + i;
			Teach fact = new Teach(type, instructor, groupNum, tutNum, groupName, firstYear, subject, hall, slot);
			facts.add(fact);
		}
		
		return facts;
	}
	
	public static ArrayList<Teach> createFreeFacts( String[] tutsInGroup, int groupNum, String groupName, int firstYear, int slot ) {
		ArrayList<Teach> facts = new ArrayList<Teach>();
		int startTut = Integer.parseInt(tutsInGroup[0]);
		int endTut = Integer.parseInt(tutsInGroup[1]);
		
		for( int i = startTut; i <= endTut; i++) {
			String tutNum = "" + i;
			Teach fact = new Teach(3,"_",groupNum, tutNum, groupName, firstYear, "FREE", 0, slot);
			facts.add(fact);
		}
		
		return facts;
	}
}
