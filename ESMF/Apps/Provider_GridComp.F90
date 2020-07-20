#include "MAPL_Generic.h"

module Provider_GridCompMod
    use ESMF
    use MAPL

    implicit none
    private

    public SetServices

    include "mpif.h"
contains
    subroutine SetServices(gc,rc)
        type(ESMF_GridComp), intent(INOUT) :: gc
        integer,             intent(  OUT) :: rc

        character(len=ESMF_MAXSTR) :: comp_name

        __Iam__('SetServices')
        call ESMF_GridCompGet(gc, name=comp_name, __RC__)
        Iam = trim(comp_name) //'::'// Iam

        print*, "Provider start Set Services"

        print*, "Provider Entry Points"
        call MAPL_GridCompSetEntryPoint(gc, ESMF_METHOD_INITIALIZE, Initialize, __RC__)
        call MAPL_GridCompSetEntryPoint(gc, ESMF_METHOD_RUN, Run, __RC__)

        print*, "Provider set export"
        call MAPL_AddExportSpec(GC,&
                short_name='var1', &
                long_name='na' , &
                units = 'na', &
                dims = MAPL_DimsHorzOnly, &
                vlocation = MAPL_VLocationNone, __RC__)

        print*, "Provider Call Generic Set Services"
        call MAPL_GenericSetServices(gc, __RC__)

        print*, "Provider finish Set Services"
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

        print*, "Provider start Initialize"

        print*, "Provider MAPL_GridCreate"
        call MAPL_GridCreate(gc, __RC__)

        print*, "Provider Generic initialize"
        call MAPL_GenericInitialize(gc, import, export, clock, __RC__)
        print*, "Provider Force allocate"
        call ForceAllocation(export, __RC__)

        print*, "Provider finish Initialize"
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

        print*, "Provider start Run"

        print*,"Provider set export value"
        call MAPL_GetPointer(export, ptr2d, 'var1', __RC__)
        ptr2d = ptr2d + 1.0

        print*, "Provider finish Run"
        _RETURN(_SUCCESS)
    end subroutine Run

    subroutine ForceAllocation(state, rc)
        type(ESMF_State),  intent(inout) :: state
        integer, optional, intent(  out) :: rc

        integer                                 :: itemCount, i, dims
        character(len=ESMF_MAXSTR), allocatable :: itemNameList(:)
        type(ESMF_StateItem_FLAG),  allocatable :: itemTypeList(:)

        type(ESMF_Field) :: field
        real, pointer    :: ptr2d(:,:), ptr3d(:,:,:)

        __Iam__('ForceAllocation')

        call ESMF_StateGet(state, itemCount=itemCount, __RC__)
        allocate(itemNameList(itemCount), stat=status)
        VERIFY_(status)
        allocate(itemTypeList(itemCount), stat=status)
        VERIFY_(status)

        call ESMF_StateGet(state, itemNameList=itemNameList, &
                itemTypeList=itemTypeList, __RC__)

        if (itemCount /= 0) then
            do i=1, itemCount
                if (itemTypeList(i) == ESMF_STATEITEM_FIELD) then
                    call ESMF_StateGet(state, trim(itemNameList(i)), field, __RC__)
                    call ESMF_AttributeGet(field, name='DIMS', value=dims, __RC__)
                    if (dims == MAPL_DimsHorzOnly) then
                        call MAPL_GetPointer(state, ptr2d, trim(itemNameList(i)), &
                                alloc=.true., __RC__)
                    else if (dims == MAPL_DimsHorzVert) then
                        call MAPL_GetPointer(state, ptr3d, trim(itemNameList(i)), &
                                alloc=.true., __RC__)
                    else
                        _ASSERT((1 == 2), "invalid field for test defined")
                    end if
                end if
            end do
        end if

        _RETURN(_SUCCESS)
    end subroutine ForceAllocation
end module Provider_GridCompMod
