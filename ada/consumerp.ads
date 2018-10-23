with Bufferp; use Bufferp;
with Ada.Numerics.Discrete_Random;

package ConsumerP is 
  B: Buffer;
  task type Consumer is
      entry Start(Consumer_Number: in Consumer_Type;
		    Consumption_Time: in Integer);
   end Consumer;
end ConsumerP;
