with Ada.Text_IO; use Ada.Text_IO;
package body BufferP is
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
end BufferP;
