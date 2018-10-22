with Bufferp; use Bufferp;
package ProducerP is
task type Producer is
      entry Start(Product: in Product_Type; Production_Time: in Integer);
   end Producer;

end ProducerP;
