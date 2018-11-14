#include <iostream>
#include <string>
#include <mogslib/mogslib.h>

#include <boost/python.hpp>

using Index = MOGSLib::Index;
using Load = MOGSLib::Load;

/* Information that can be used to call a scheduling algorithm */
namespace SchedulerData {
    Index ntasks;
    Index npes;
    std::string scheduler;
    Load* task_loads;
}

namespace { // Avoiding name conflicts

/* Dummy class to call MOGSLib schedulers
 */
struct Scheduler {
    /* Interface to call load-oblivious schedulers
     */
    boost::python::list load_oblivious (
            std::string scheduler,
            int npes,
            int ntasks
        ) {
        // Set values
        SchedulerData::ntasks = ntasks;
        SchedulerData::npes = npes;
        SchedulerData::scheduler = scheduler;

        // Inform MOGSLib of the values
        MOGSLib::RTS::set_ntasks(ntasks);
        MOGSLib::RTS::set_nPEs(npes);
        MOGSLib::SchedulerCollection::pick_scheduler = []() {return SchedulerData::scheduler;};

        // Call scheduler
        Index* map = MOGSLib::SchedulerCollection::schedule();
        // Convert the output to a python type
        boost::python::list list;
        for( decltype(SchedulerData::ntasks) i = 0; i < SchedulerData::ntasks; ++i )
            list.append(map[i]);

        return list;
    }

    /* Simple interface to call load-aware schedulers
     */
    boost::python::list load_aware (
            std::string scheduler,
            int npes,
            int ntasks,
            boost::python::list task_loads
        ) {
        // Set values
        SchedulerData::ntasks = ntasks;
        SchedulerData::npes = npes;
        SchedulerData::scheduler = scheduler;
        SchedulerData::task_loads = new Load[SchedulerData::ntasks]();
        for( decltype(SchedulerData::ntasks) i = 0; i < SchedulerData::ntasks; ++i )
            SchedulerData::task_loads[i] = boost::python::extract<Load>(task_loads[i]);

        // Inform MOGSLib of the values
        MOGSLib::RTS::set_ntasks(ntasks);
        MOGSLib::RTS::set_nPEs(npes);
        MOGSLib::RTS::set_task_load_function( []() {return SchedulerData::task_loads;} );
        MOGSLib::SchedulerCollection::pick_scheduler = []() {return SchedulerData::scheduler;};

        // Call scheduler
        Index* map = MOGSLib::SchedulerCollection::schedule();
        // Convert the output to a python type
        boost::python::list list;
        for( decltype(SchedulerData::ntasks) i = 0; i < SchedulerData::ntasks; ++i )
            list.append(map[i]);

        return list;
    }

};

}

/* Macros to generate the python module
 */
BOOST_PYTHON_MODULE(mogslib)
{
    using namespace boost::python;
    class_<Scheduler>("Scheduler")
        .def("load_oblivious", &Scheduler::load_oblivious)
        .def("load_aware", &Scheduler::load_aware)
        ;
}

