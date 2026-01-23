import {
  Controller,
  Get,
  Post,
  Delete,
  Param,
  UseGuards,
  Req,
} from "@nestjs/common";
import { AuthGuard } from "@nestjs/passport";
import { QueueService } from "./queue.service";

@Controller("orders/:orderId/queue")
@UseGuards(AuthGuard("jwt"))
export class QueueController {
  constructor(private readonly queueService: QueueService) {}

  @Get()
  async getQueue(@Req() req, @Param("orderId") orderId: string) {
    return this.queueService.getQueue(req.user.id, orderId);
  }

  @Post()
  async joinQueue(@Req() req, @Param("orderId") orderId: string) {
    return this.queueService.joinQueue(req.user.id, orderId);
  }

  @Delete()
  async leaveQueue(@Req() req, @Param("orderId") orderId: string) {
    return this.queueService.leaveQueue(req.user.id, orderId);
  }
}
