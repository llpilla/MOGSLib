#include <gtest/gtest.h>

#include "../type_definitions.h"
#include <schedulers/task_pack.h>

using Index = MOGSLib::Index;
using Load = MOGSLib::Load;
using TaskMap = MOGSLib::TaskMap;
using TaskEntry = MOGSLib::TaskEntry;

struct DataDummyContainer {
  Index _ntasks;
  Index _nPEs;
  Index value;

  inline Index ntasks() {
    return _ntasks;
  }

  inline Index ntasks() const {
    return _ntasks;
  }

  inline Load* tasks_workloads() {
    return nullptr;
  }

  inline Index nPEs() const {
    return _nPEs;
  }

  inline Index nPEs() {
    return _nPEs;
  }

  inline Load* PEs_workloads() {
    return nullptr;
  }
};

using TestScheduler = MOGSLib::Scheduler::TaskPack<DataDummyContainer, DataDummyContainer, DataDummyContainer>;

class TaskPackSchedTests : public ::testing::Test {
public:
  TestScheduler scheduler;
  DataDummyContainer data;
  TaskMap map;

  void setTask(const Index &ntasks) {
    data._ntasks = ntasks;
  }

  void setPE(const Index &nPEs) {
    data._nPEs = nPEs;
  }

  void setpacks(const Index &npacks) {
    data.value = npacks;
  }

  void execute_scheduler() {
    map = scheduler.work();
  }

  void SetUp() {
    data._ntasks = 0;
    data._nPEs = 0;

    scheduler.init(std::make_tuple(&data,&data,&data));

    map = nullptr;
  }

  void TearDown() {
    if(map != nullptr) {
      delete [] map;
      map = nullptr;  
    }
    
  }
};

TEST_F(TaskPackSchedTests, single_task) {
  setTask(1);
  setPE(1);
  setpacks(1);

  execute_scheduler();
  ASSERT_EQ(0, map[0]);
}

TEST_F(TaskPackSchedTests, single_task_two_packs) {
  setTask(1);
  setPE(1);
  setpacks(2);

  execute_scheduler();
  ASSERT_EQ(0, map[0]);
}

TEST_F(TaskPackSchedTests, two_tasks_two_PEs_one_pack) {
  setTask(2);
  setPE(2);
  setpacks(1);

  execute_scheduler();
  ASSERT_EQ(0, map[0]);
  ASSERT_EQ(0, map[1]);
}

TEST_F(TaskPackSchedTests, two_tasks_two_PEs_two_pack) {
  setTask(2);
  setPE(2);
  setpacks(2);

  execute_scheduler();
  ASSERT_EQ(0, map[0]);
  ASSERT_EQ(1, map[1]);
}

TEST_F(TaskPackSchedTests, odd_tasks_even_packs) {
  setTask(5);
  setPE(3);
  setpacks(3);

  execute_scheduler();
  EXPECT_EQ(0, map[0]);
  EXPECT_EQ(0, map[1]);
  EXPECT_EQ(0, map[2]);
  EXPECT_EQ(1, map[3]);
  EXPECT_EQ(2, map[4]);
}

TEST_F(TaskPackSchedTests, less_PEs_than_packs) {
  setTask(5);
  setPE(2);
  setpacks(3);

  execute_scheduler();
  EXPECT_EQ(0, map[0]);
  EXPECT_EQ(0, map[1]);
  EXPECT_EQ(0, map[2]);
  EXPECT_EQ(1, map[3]);
  EXPECT_EQ(0, map[4]);
}

TEST_F(TaskPackSchedTests, more_PEs_than_packs) {
  setTask(5);
  setPE(4);
  setpacks(2);

  execute_scheduler();
  EXPECT_EQ(0, map[0]);
  EXPECT_EQ(0, map[1]);
  EXPECT_EQ(0, map[2]);
  EXPECT_EQ(1, map[3]);
  EXPECT_EQ(1, map[4]);
}