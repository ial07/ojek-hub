import {
  Controller,
  Get,
  Post,
  Put,
  Body,
  Req,
  UnauthorizedException,
} from "@nestjs/common";
import { UsersService } from "./users.service";
import { UpdateUserDto } from "./dto/update-user.dto";

class UpdateRoleDto {
  role: string;
  workerType?: string;
}

@Controller("users")
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  /**
   * Helper to extract user from JWT
   */
  private async getUserFromRequest(req: any) {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      throw new UnauthorizedException("Missing Authorization header");
    }
    const token = authHeader.replace("Bearer ", "");
    return this.usersService.extractUserFromToken(token);
  }

  /**
   * Get current user profile
   */
  @Get("me")
  async getProfile(@Req() req) {
    const user = await this.getUserFromRequest(req);
    return this.usersService.getProfile(user.id);
  }

  /**
   * Update current user profile
   */
  @Put("me")
  async updateProfile(@Req() req, @Body() updateUserDto: UpdateUserDto) {
    const user = await this.getUserFromRequest(req);
    return this.usersService.updateProfile(user.id, updateUserDto);
  }

  /**
   * Update user role (POST /users/role)
   */
  @Post("role")
  async updateRole(@Req() req, @Body() dto: UpdateRoleDto) {
    const user = await this.getUserFromRequest(req);
    return this.usersService.updateRole(user.id, dto.role, dto.workerType);
  }
}
