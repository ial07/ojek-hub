import { IsBoolean, IsOptional } from "class-validator";

export class UpdateWorkerProfileDto {
  @IsBoolean()
  @IsOptional()
  isAvailable?: boolean;
}
