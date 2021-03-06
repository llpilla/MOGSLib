#pragma once

namespace MOGSLib {

/**
 * @brief An enumerate of all the supported runtime systems for MOGSLib schedulers.
 */
enum RuntimeSystemEnum {
  NoRTS,
  Custom,
  Charm,
  OpenMP
};

/**
 * @brief An enumerate of all the schedulers that MOGSLib can expose.
 */
enum SchedulerEnum {
  round_robin,
  compact,
  task_pack,
  greedy,
  binlpt
};

}