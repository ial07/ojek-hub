import {
  IsString,
  IsNotEmpty,
  IsIn,
  IsOptional,
  IsEmail,
} from "class-validator";

export class RegisterDto {
  @IsString()
  @IsOptional()
  token?: string;

  @IsEmail()
  @IsNotEmpty()
  email: string;

  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsOptional() // Made optional for initial registration
  phone?: string;

  @IsString()
  @IsOptional() // Made optional for initial registration
  location?: string;

  @IsString()
  @IsNotEmpty()
  @IsIn(["farmer", "warehouse", "worker"])
  role: string;

  @IsString()
  @IsOptional()
  @IsIn(["ojek", "pekerja"])
  workerType?: string;

  @IsString()
  @IsOptional()
  supabaseUserId?: string;
}
