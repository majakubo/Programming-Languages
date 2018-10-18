with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; 
with Ada.Numerics.Discrete_Random;


procedure Simulation is
   Number_Of_Products: constant Integer := 5;
   Number_Of_Assemblies: constant Integer := 3;
   Number_Of_Consumers: constant Integer := 2;
   subtype Production_Time_Range is Integer range 3 .. 6;
   subtype Consumption_Time_Range is Integer range 4 .. 8;
   subtype Product_Type is Integer range 1 .. Number_Of_Products;
   subtype Assembly_Type is Integer range 1 .. Number_Of_Assemblies;
   subtype Consumer_Type is Integer range 1 .. Number_Of_Consumers;
   Product_Name: constant array (Product_Type) of String(1 .. 8)
     := ("Fries   ", "DietCola", "BigMac  ", "Salad   ", "McWrap  ");
   Assembly_Name: constant array (Assembly_Type) of String(1 .. 9)
     := ("HappyMeal", "BigMacPro", "VeganYou ");
   package Random_Consumption is new
     Ada.Numerics.Discrete_Random(Consumption_Time_Range);
   package Random_Assembly is new
     Ada.Numerics.Discrete_Random(Assembly_Type);
   type My_Str is new String(1 ..256);

   task type Producer is
      entry Start(Product: in Product_Type; Production_Time: in Integer);
   end Producer;

   task type Consumer is
      entry Start(Consumer_Number: in Consumer_Type;
		    Consumption_Time: in Integer);
   end Consumer;

   task type Buffer is
      entry Take(Product: in Product_Type; Number: in Integer; IsTaken: out Boolean);
      entry Deliver(Assembly: in Assembly_Type; Number: out Integer);
   end Buffer;

   P: array ( 1 .. Number_Of_Products ) of Producer;
   K: array ( 1 .. Number_Of_Consumers ) of Consumer;
   B: Buffer;

   task body Producer is
      package Random_Production is new
	Ada.Numerics.Discrete_Random(Production_Time_Range);
      G: Random_Production.Generator;	      
      Product_Type_Number: Integer;
      Product_Number: Integer;
      Production: Integer;
      IsTaken: Boolean;
   begin
      accept Start(Product: in Product_Type; Production_Time: in Integer) do
	 Random_Production.Reset(G);		 
	 Product_Number := 1;
	 Product_Type_Number := Product;
	 Production := Production_Time;
      end Start;
      Put_Line("Okey Let's do " & Product_Name(Product_Type_Number));
      loop
	 delay Duration(Random_Production.Random(G)); 
	 Put_Line("Hey I made " & Product_Name(Product_Type_Number)
		    & " i have "  & Integer'Image(Product_Number) & " of them");
	 
	 loop
	    B.Take(Product_Type_Number, Product_Number, IsTaken);
	    if IsTaken then
               exit;
	    end if;
	 end loop;

      end loop;
   end Producer;

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

   task body Buffer is
      Storage_Capacity: constant Integer := 30;
      type Storage_type is array (Product_Type) of Integer;
      Storage: Storage_type
	:= (0, 0, 0, 0, 0);
      Assembly_Content: array(Assembly_Type, Product_Type) of Integer
	:= ((1, 1, 0, 1, 1),
	    (2, 2, 2, 0, 0),
	    (2, 1, 0, 2, 0));
      Max_Assembly_Content: array(Product_Type) of Integer;
      Assembly_Number: array(Assembly_Type) of Integer
	:= (1, 1, 1);
      In_Storage: Integer := 0;

      procedure Setup_Variables is
      begin
	 for W in Product_Type loop
	    Max_Assembly_Content(W) := 0;
	    for Z in Assembly_Type loop
	       if Assembly_Content(Z, W) > Max_Assembly_Content(W) then
		  Max_Assembly_Content(W) := Assembly_Content(Z, W);
	       end if;
	    end loop;
	 end loop;
      end Setup_Variables;

      function Can_Accept(Product: Product_Type) return Boolean is
	 Free: Integer;		
	 Lacking: array(Product_Type) of Integer;
	 Lacking_room: Integer;
	 MP: Boolean;			
      begin
	 if In_Storage >= Storage_Capacity then
	    return False;
	 end if;
	 
	 Free := Storage_Capacity - In_Storage;
	 MP := True;
	 
	 for W in Product_Type loop
	    if Storage(W) < Max_Assembly_Content(W) then
	       MP := False;
	    end if;
	 end loop;
	 if MP then
	    return True;		
	       			
	 end if;
	 if Integer'Max(0, Max_Assembly_Content(Product) - Storage(Product)) > 0 then
	    
	    return True;
	 end if;
	 Lacking_room := 1;			
	 for W in Product_Type loop
	    Lacking(W) := Integer'Max(0, Max_Assembly_Content(W) - Storage(W));
	    Lacking_room := Lacking_room + Lacking(W);
	 end loop;
	 if Free >= Lacking_room then
	    return True;
	 else
	    return False;
	 end if;
      end Can_Accept;

      function Can_Deliver(Assembly: Assembly_Type) return Boolean is
      begin
	 for W in Product_Type loop
	    if Storage(W) < Assembly_Content(Assembly, W) then
	       return False;
	    end if;
	 end loop;
	 return True;
      end Can_Deliver;

      procedure Storage_Contents is
      begin
	 for W in Product_Type loop
	    Put_Line("Storage contents: " & Integer'Image(Storage(W)) & " "
		       & Product_Name(W));
	 end loop;
      end Storage_Contents;

   begin
      Put_Line("McDonald's is open! Welcome everybody");
      Setup_Variables;
      loop
         select
	    accept Deliver(Assembly: in Assembly_Type; Number: out Integer) do
	        if Can_Deliver(Assembly) then
	          Put_Line("Here's your's " & Assembly_Name(Assembly) & " in amount of " &
		  	     Integer'Image(Assembly_Number(Assembly)));
	          for W in Product_Type loop
		     Storage(W) := Storage(W) - Assembly_Content(Assembly, W);
		     In_Storage := In_Storage - Assembly_Content(Assembly, W);
	          end loop;
	          Number := Assembly_Number(Assembly);
	          Assembly_Number(Assembly) := Assembly_Number(Assembly) + 1;
	       else
	          Put_Line("One moment, you need to wait a bit longer");
	       end if;
	    end Deliver;
	 or   
            accept Take(Product: in Product_Type; Number: in Integer; IsTaken: out Boolean) do
	      if Can_Accept(Product) then
	         Put_Line("Thank you for " & Integer'Image(Number) & "  " & Product_Name(Product));
	         Storage(Product) := Storage(Product) + 1;
	         In_Storage := In_Storage + 1;
		 IsTaken := True;

  	      else
	         Put_Line("Sorry I can't take " & Integer'Image(Number) & " " & Product_Name(Product));
		 IsTaken := False;
	      end if;
	    end Take;
         end select;

	 --Storage_Contents;
      end loop;
   end Buffer;
   
begin
   for I in 1 .. Number_Of_Products loop
      P(I).Start(I, 10);
   end loop;
   for J in 1 .. Number_Of_Consumers loop
      K(J).Start(J,12);
   end loop;
end Simulation;


