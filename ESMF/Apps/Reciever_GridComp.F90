#include "MAPL_Generic.h"

module Reciever_GridCompMod
    use ESMF
    use MAPL

    implicit none
    private

    public SetServices

    include "mpif.h"
contains
    subroutine SetServices(gc, rc)
        type(ESMF_GridComp), intent(inout) :: gc
        integer,             intent(  out) :: rc

        character(len=ESMF_MAXSTR) :: comp_name

        __Iam__('SetServices')
        call ESMF_GridCompGet(gc, name=comp_name, __RC__)
        Iam = trim(comp_name) //'::'// Iam

        print*, "Reciever start Set Services"

        print*, "Reciever Entry Points"
        call MAPL_GridCompSetEntryPoint(gc, ESMF_METHOD_INITIALIZE, Initialize, __RC__)
        call MAPL_GridCompSetEntryPoint(gc, ESMF_METHOD_RUN, Run, __RC__)

        print*, "Reciever set import"
        call MAPL_AddImportSpec(gc, &
                short_name='var1', &
                long_name='na', &
                units='na', &
                dims=MAPL_DimsHorzOnly, &
                vlocation=MAPL_VLocationNone, __RC__)

        print*, "Reciever Call Generic Set Services"
        call MAPL_GenericSetServices(gc, __RC__)

        print*, "Reciever finish Set Services"
        _RETURN(_SUCCESS)
    end subroutine SetServices

    subroutine Initialize(gc, import, export, clock, rc)
        type(ESMF_GridComp), intent(inout) :: gc
        type(ESMF_State),    intent(inout) :: import
        type(ESMF_State),    intent(inout) :: export
        type(ESMF_Clock),    intent(inout) :: clock
        integer, optional,   intent(  out) :: rc

        character(len=ESMF_MAXSTR) :: comp_name

        __Iam__('Initialize')
        call ESMF_GridCompGet(gc, name=comp_name, __RC__)
        Iam = trim(comp_name) //'::'// Iam

        print*, "Reciever start Initialize"

        print*, "Provider MAPL_GridCreate"
        call MAPL_GridCreate(gc, __RC__)

        print*, "Reciever Generic initialize"
        call MAPL_GenericInitialize(gc, import, export, clock, __RC__)

        print*, "Reciever finish Initialize"
        _RETURN(_SUCCESS)
    end subroutine Initialize

    subroutine Run(gc, import, export, clock, rc)
        type(ESMF_GridComp), intent(inout) :: gc
        type(ESMF_State),    intent(inout) :: import
        type(ESMF_State),    intent(inout) :: export
        type(ESMF_Clock),    intent(inout) :: clock
        integer, optional,   intent(  out) :: rc

        character(len=ESMF_MAXSTR) :: comp_name
        real, pointer              :: ptr2d(:,:)

        __Iam__('Run')
        call ESMF_GridCompGet(gc, name=comp_name, __RC__)
        Iam = trim(comp_name) //'::'// Iam

        print*, "Reciever start Run"

        print*,"Reciever get import value"
        call MAPL_GetPointer(import, ptr2d, 'var1', __RC__)
        print*, 'The value of var1 is:', minval(ptr2d), maxval(ptr2d)

        print*, "Reciever finish Run"
        _RETURN(_SUCCESS)
    end subroutine Run
end module Reciever_GridCompMod