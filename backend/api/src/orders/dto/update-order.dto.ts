import { IsString, IsOptional, IsIn } from "class-validator";

export class UpdateOrderDto {
  @IsString()
  @IsIn(["open", "closed"])
  @IsOptional()
  status?: string;
}
