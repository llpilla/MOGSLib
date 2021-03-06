#pragma once

#include <abstractions/scheduler.h>
#include <policies/task_pack.h>

namespace MOGSLib { namespace Scheduler {

/**
 * @brief Class that represents a scheduler which utilizes the compact policy to output a task map.
 **/
template<typename ... _Concepts>
class TaskPack : public Abstraction::Scheduler<MOGSLib::SchedulerEnum::task_pack, _Concepts...> {
public:
  using Base = Abstraction::Scheduler<MOGSLib::SchedulerEnum::task_pack, _Concepts...>;

  /**
   * @brief The method to obtain a task map based on a compact policy.
   **/
  TaskMap work() override {
    auto concepts = Base::concepts;
    
    auto ntasks = concepts->task_data->ntasks();
    auto nPEs = concepts->PE_data->nPEs();
    auto npacks = concepts->k->value;

    auto map = new Index[ntasks]();
    Policy::TaskPack::map(map, ntasks, nPEs, npacks);
    return map;
  }

};

}}