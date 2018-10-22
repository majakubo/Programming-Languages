
package BufferP is
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
   type My_Str is new String(1 ..256);
    task type Buffer is
      entry Take(Product: in Product_Type; Number: in Integer; IsTaken: out Boolean);
      entry Deliver(Assembly: in Assembly_Type; Number: out Integer);
   end Buffer;
end BufferP;
