with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Discrete_Random;

package body ProducerP is
task body Producer is
      package Random_Production is new
	Ada.Numerics.Discrete_Random(Production_Time_Range);
      G: Random_Production.Generator;	      
      Product_Type_Number: Integer;
      Product_Number: Integer;
      Production: Integer;
      IsTaken: Boolean;
      Attemps: Integer;       
      except: exception;
   begin
      accept Start(Product: in Product_Type; Production_Time: in Integer) do
	 Random_Production.Reset(G);		 
	 Product_Number := 1;
	 Product_Type_Number := Product;
	 Production := Production_Time;
      end Start;
      Put_Line("Okey Let's do " & Product_Name(Product_Type_Number));
      loop 
	 begin
	    delay Duration(Random_Production.Random(G)); 
	    Put_Line("Hey I made " & Product_Name(Product_Type_Number)
		    & " i have "  & Integer'Image(Product_Number) & " of them");
	    Attemps := 0;
	    loop
	       B.Take(Product_Type_Number, Product_Number, IsTaken);
	       Attemps := Attemps +  1;
	       if Attemps = 3 then
                  raise except;
	       end if;
	       if IsTaken then
                  exit;
	       end if;
	       delay 3.0;
	    end loop;
	 exception
	    when except =>
               Put_Line("Sorry food it's too cold i need to put it to trash");
	 end;
      end loop;
   end Producer;
end ProducerP;
