import java.io.*;

public class trace_generator{
   
   public static final int OPCODE_LNEGTH = 7;
   public static final int NODE_ID_LENGTH = 4;
   public static final int DATA_NOT_RESET_LENGTH = 1;
   public static final int DATA_LENGTH = 75;
     
   
   
   public static String wait_a_cycle = "0000";
   public static String send = "0001";
   public static String receive_check = "0010";
   public static String done = "0011";
   public static String end = "0100";
   public static String wait_counter = "0101";
   public static String set_counter = "0110";
   
   public static String disable = "0000001";
   public static String enable = "0000010";
   public static String assert_reset = "0000101";
   public static String deassert_reset = "0000110";
   
   

   
   public static void main(String[] args) throws FileNotFoundException {
      File trace_file = new File("trace.tr");
      PrintStream printTrace = new PrintStream(trace_file);
      PrintStream hexTrace = new PrintStream(new File("hex_trace.tr"));
      for (int i = 0; i < 100; i++) {
         printTrace.println(trace_gen(send, "0", i));
         printTrace.println(trace_gen(set_counter, "0", 100));
         printTrace.println(trace_gen(wait_counter, "0", 0));
         int data = Integer.parseInt(trace_gen(send, "0", i).substring(5,80));
         hexTrace.println(Integer.toHexString(data));
         // printTrace.println(trace_gen(receive_check, "0", 0));
      }
   }
   
   public static String trace_gen(String op, String isSwitch, int data) {          
      String trace = op + isSwitch;
      String data_str = Integer.toBinaryString(data);
      String data_paddedStr = padData(data_str);
      trace = trace + data_paddedStr;
      return trace;
   }
   
   public static String padData(String data) {
      if (data.length() < DATA_LENGTH) {
         String pad = "";
         for (int i = 0; i < DATA_LENGTH - data.length(); i++) {
            pad = pad + "0";
         }
         return pad + data;       
      }
      return data;
   }
}