import { Injectable } from "@nestjs/common";
import { CreateWorkerProfileDto } from "./dto/create-worker-profile.dto";
import { UpdateWorkerProfileDto } from "./dto/update-worker-profile.dto";

@Injectable()
export class WorkersService {
  async getWorkerProfile() {
    // Business logic will be implemented later
    return { pesan: "Data profil pekerja" };
  }

  async createWorkerProfile(createDto: CreateWorkerProfileDto) {
    // Business logic will be implemented later
    return { pesan: "Profil pekerja berhasil dibuat" };
  }

  async updateWorkerProfile(updateDto: UpdateWorkerProfileDto) {
    // Business logic will be implemented later
    return { pesan: "Profil pekerja berhasil diperbarui" };
  }
}
