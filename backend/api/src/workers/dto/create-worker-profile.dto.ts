import { IsString, IsIn } from "class-validator";

export class CreateWorkerProfileDto {
  @IsString()
  @IsIn(["ojek", "pekerja"])
  workerType: string;
}
