public class Fossil.Util.Intparser {

	public static bool try_parse_unsigned(string input,out uint64 integer){
		bool success = false;	
		integer = 0;
		for (int i = 0; i<input.length; i++){
			unichar nextchar = input.get_char(i);
			if (nextchar == '0') {
				integer = integer*10;
			} else if (nextchar == '1') {
				integer = integer*10+1;
			} else if (nextchar == '2') {
				integer = integer*10+2;
			} else if (nextchar == '3') {
				integer = integer*10+3;
			} else if (nextchar == '4') {
				integer = integer*10+4;
			} else if (nextchar == '5') {
				integer = integer*10+5;
			} else if (nextchar == '6') {
				integer = integer*10+6;
			} else if (nextchar == '7') {
				integer = integer*10+7;
			} else if (nextchar == '8') {
				integer = integer*10+8;
			} else if (nextchar == '9') {
				integer = integer*10+9;
			} else {
				break;
			}
			success = true;
		}
		return success;
	}
	
	public static bool try_parse_base_16_unsigned(string input,out uint64 integer){
		bool success = false;	
		integer = 0;
		for (int i = 0; i<input.length; i++){
			unichar nextchar = input.get_char(i);
			if (nextchar == '0') {
				integer = integer*16;
			} else if (nextchar == '1') {
				integer = integer*16+1;
			} else if (nextchar == '2') {
				integer = integer*16+2;
			} else if (nextchar == '3') {
				integer = integer*16+3;
			} else if (nextchar == '4') {
				integer = integer*16+4;
			} else if (nextchar == '5') {
				integer = integer*16+5;
			} else if (nextchar == '6') {
				integer = integer*16+6;
			} else if (nextchar == '7') {
				integer = integer*16+7;
			} else if (nextchar == '8') {
				integer = integer*16+8;
			} else if (nextchar == '9') {
				integer = integer*16+9;
			} else if (nextchar == 'a' || nextchar == 'A') {
				integer = integer*16+10;
			} else if (nextchar == 'b' || nextchar == 'B') {
				integer = integer*16+11;
			} else if (nextchar == 'c' || nextchar == 'C') {
				integer = integer*16+12;
			} else if (nextchar == 'd' || nextchar == 'D') {
				integer = integer*16+13;
			} else if (nextchar == 'e' || nextchar == 'E') {
				integer = integer*16+14;
			} else if (nextchar == 'f' || nextchar == 'F') {
				integer = integer*16+15;
			} else {
				break;
			}
			success = true;
		}
		return success;
	}
	
}
