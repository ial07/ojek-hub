import { Controller, Get, Post, Put, Body } from "@nestjs/common";
import { WorkersService } from "./workers.service";
import { CreateWorkerProfileDto } from "./dto/create-worker-profile.dto";
import { UpdateWorkerProfileDto } from "./dto/update-worker-profile.dto";

@Controller("workers")
export class WorkersController {
  constructor(private readonly workersService: WorkersService) {}

  @Get("profile")
  async getWorkerProfile() {
    return this.workersService.getWorkerProfile();
  }

  @Post("profile")
  async createWorkerProfile(@Body() createDto: CreateWorkerProfileDto) {
    return this.workersService.createWorkerProfile(createDto);
  }

  @Put("profile")
  async updateWorkerProfile(@Body() updateDto: UpdateWorkerProfileDto) {
    return this.workersService.updateWorkerProfile(updateDto);
  }
}
