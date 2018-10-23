with Ada.Text_IO; use Ada.Text_IO;

package body ConsumerP is
task body Consumer is
      G: Random_Consumption.Generator;	
      G2: Random_Assembly.Generator;	
      Consumer_Nb: Consumer_Type;
      Assembly_Number: Integer;
      Consumption: Integer;
      Assembly_Type: Integer;
      Consumer_Name: constant array (1 .. Number_Of_Consumers)
	of String(1 .. 9)
	:= ("Students ", "Family   ");
      
   begin
      accept Start(Consumer_Number: in Consumer_Type;
		     Consumption_Time: in Integer) do
	 Random_Consumption.Reset(G);	
	 Random_Assembly.Reset(G2);	
	 Consumer_Nb := Consumer_Number;
         Consumption := Consumption_Time;
      end Start;
      Put_Line("Wow,  " & Consumer_Name(Consumer_Nb) & " came to McDonald hungry as always!");
      loop
	 delay Duration(Random_Consumption.Random(G)); 
	 Assembly_Type := Random_Assembly.Random(G2);
	 Put_line("Hi We as a " & Consumer_Name(Consumer_Nb) & " would like to order " & Assembly_Name(Assembly_Type));
	 select
	    delay 10.0;
	    Put_Line("That's to long for us(" & Consumer_Name(Consumer_Nb) & ") sorry we are out, we will go elsewhere");
	 then abort		 
	    loop
	       delay 1.0;	    
               B.Deliver(Assembly_Type, Assembly_Number);
	       if Assembly_Number /= 0 then
	          Put_Line(Consumer_Name(Consumer_Nb) & " says: thank you very much for delicious  " &
	          Assembly_Name(Assembly_Type) & " We're glad we ordered " &
	          Integer'Image(Assembly_Number) & " because We are hungry");
	          exit;
	       end if;
            end loop;
         end select;
      end loop;
   end Consumer;
   
end ConsumerP;
