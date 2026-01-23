import {
  IsString,
  IsInt,
  IsIn,
  IsDateString,
  Min,
  IsNotEmpty,
  IsOptional,
  IsNumber,
} from "class-validator";
import { Type } from "class-transformer";

export class CreateOrderDto {
  @IsString()
  @IsNotEmpty()
  @IsIn(["ojek", "pekerja"])
  workerType: string;

  @IsInt()
  @Min(1)
  @Type(() => Number)
  workerCount: number;

  @IsString()
  @IsNotEmpty()
  description: string;

  @IsString()
  @IsNotEmpty()
  location: string;

  @IsDateString()
  @IsNotEmpty()
  jobDate: string;

  @IsOptional()
  @IsNumber()
  latitude?: number;

  @IsOptional()
  @IsNumber()
  longitude?: number;

  @IsOptional()
  @IsString()
  mapUrl?: string;
}
