import { IsString, IsOptional, IsIn } from "class-validator";

export class UpdateOrderDto {
  @IsString()
  @IsIn(["open", "closed"])
  @IsOptional()
  status?: string;

  @IsOptional()
  workerCount?: number;

  @IsOptional()
  description?: string;

  @IsOptional()
  location?: string;

  @IsOptional()
  jobDate?: string;

  @IsOptional()
  latitude?: number;

  @IsOptional()
  longitude?: number;

  @IsOptional()
  mapUrl?: string;
}
