#!/bin/sh
#
# <meta:header>
#   <meta:licence>
#     Copyright (c) 2020, ROE (http://www.roe.ac.uk/)
#
#     This information is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     This information is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>.
#   </meta:licence>
# </meta:header>
#
#

# -----------------------------------------------------
# Cloud config.

    echo "---- ----"
    echo "Cloud config [${cloudname:?}]"

# -----------------------------------------------------
# Delete all the servers.

    echo ""
    echo "---- ----"
    echo "Deleting servers"

    for serverid in $(
        openstack \
            --os-cloud "${cloudname:?}" \
            server list \
                --format json \
        | jq -r '.[] | .ID'
        )
    do
        echo "Deleting server [${serverid:?}]"
        openstack \
            --os-cloud "${cloudname:?}" \
            server delete \
                "${serverid:?}"
    done

# -----------------------------------------------------
# Delete all the volumes.


    echo ""
    echo "---- ----"
    echo "Deleting volumes"

    for volumeid in $(
        openstack \
            --os-cloud "${cloudname:?}" \
            volume list \
                --format json \
        | jq -r '.[] | .ID'
        )
    do
        echo "Deleting volume [${volumeid:?}]"
        openstack \
            --os-cloud "${cloudname:?}" \
            volume delete \
                "${volumeid:?}"
    done

# -----------------------------------------------------
# Release all the floating IP addresses.

    echo ""
    echo "---- ----"
    echo "Releasing addresses"

    for floatingid in $(
        openstack \
            --os-cloud "${cloudname:?}" \
            floating ip list \
                --format json \
        | jq -r '.[] | .ID'
        )
        do
            echo "Releasing address [${floatingid:?}]"
            openstack \
                --os-cloud "${cloudname:?}" \
                floating ip unset \
                    "${floatingid}"

            openstack \
                --os-cloud "${cloudname:?}" \
                floating ip delete \
                    "${floatingid}"
        done


# -----------------------------------------------------
# Delete all the routers.

    echo ""
    echo "---- ----"
    echo "Deleting routers"

    for routerid in $(
        openstack \
            --os-cloud "${cloudname:?}" \
            router list \
                --format json \
        | jq -r '.[] | .ID'
        )
    do

        echo "----"
        echo "Router [${routerid:?}]"

        echo "----"
        echo "Deleting routes"
        for routedesc in $(
            openstack \
                --os-cloud "${cloudname:?}" \
                router show \
                    --format json \
                    "${routerid:?}" \
            | jq -r '.routes[] | "gateway=" + .nexthop + ",destination=" + .destination'
            )
        do
            echo "Deleting route [${routedesc:?}]"
            openstack \
                --os-cloud "${cloudname:?}" \
                router unset \
                    --route "${routedesc:?}" \
                    "${routerid:?}"
        done

        echo "----"
        echo "Deleting ports"
        for portid in $(
            openstack \
                --os-cloud "${cloudname:?}" \
                router show \
                    --format json \
                    "${routerid:?}" \
                | jq -r '.interfaces_info[].port_id'
                )
                do
                    echo "Deleting port [${portid}]"
                    openstack \
                        --os-cloud "${cloudname:?}" \
                        router remove port \
                            "${routerid:?}" \
                            "${portid:?}"
                done

        echo "----"
        echo "Deleting router [${routerid:?}]"
        openstack \
            --os-cloud "${cloudname:?}" \
            router delete \
                "${routerid:?}"
    done


# -----------------------------------------------------
# Delete any extra subnets.
#[user@openstacker]

    echo ""
    echo "---- ----"
    echo "Deleting subnets"

    for subnetid in $(
        openstack \
            --os-cloud "${cloudname:?}" \
            subnet list \
                --format json \
        | jq -r '.[] | select(
            (.Name != "internet")
            and
            (.Name != "cumulus-internal")
            ) | .ID'
        )
    do
        echo "----"
        echo "Subnet [${subnetid:?}]"

        echo "----"
        echo "Deleting subnet ports"
        for subportid in $(
                openstack \
                    --os-cloud "${cloudname:?}" \
                    port list \
                        --fixed-ip "subnet=${subnetid:?}" \
                        --format json \
                | jq -r '.[] | .ID'
                )

        do
            echo "Deleting subnet port [${subportid:?}]"
            openstack \
                --os-cloud "${cloudname:?}" \
                port delete \
                    "${subportid:?}"

        done

        echo "Deleting subnet [${subnetid:?}]"
        openstack \
            --os-cloud "${cloudname:?}" \
            subnet delete \
                "${subnetid:?}"
    done


# -----------------------------------------------------
# Delete any extra networks.
#[user@openstacker]

    echo ""
    echo "---- ----"
    echo "Deleting networks"

    for networkid in $(
        openstack \
            --os-cloud "${cloudname:?}" \
            network list \
                --format json \
        | jq -r '.[] | select(
            (.Name != "internet")
            and
            (.Name != "cumulus-internal")
            ) | .ID'
        )
    do
        echo "Deleting network [${networkid:?}]"
        openstack \
            --os-cloud "${cloudname:?}" \
            network delete \
                "${networkid:?}"
    done


# -----------------------------------------------------
# Delete all the security groups.
#[user@openstacker]

    echo ""
    echo "---- ----"
    echo "Deleting security groups"

    for groupid in $(
        openstack \
            --os-cloud "${cloudname:?}" \
            security group list \
                --format json \
        | jq -r '.[] | select(.Name != "default") | .ID'
        )
    do
        echo "Deleting group [${groupid:?}]"
        openstack \
            --os-cloud "${cloudname:?}" \
            security group delete \
                "${groupid:?}"
    done


# -----------------------------------------------------
# Delete any Mangum clusters.
#[user@openstacker]

    echo ""
    echo "---- ----"
    echo "Deleting clusters"

    for clusterid in $(
        openstack \
            --os-cloud "${cloudname:?}" \
            coe cluster list \
                --format json \
        | jq -r '.[] | .uuid'
        )
    do
        echo "Deleting cluster [${clusterid:?}]"
        openstack \
            --os-cloud "${cloudname:?}" \
            coe cluster \
                delete \
                "${clusterid:?}"
        echo "Pause ..."
        sleep 30
    done


# -----------------------------------------------------
# List the remaining resources.
#[user@openstacker]

    echo ""
    echo "---- ----"
    echo "List servers"
    openstack \
        --os-cloud "${cloudname:?}" \
        server list

    echo "---- ----"
    echo "List addresses"
    openstack \
        --os-cloud "${cloudname:?}" \
        floating ip list

    echo "---- ----"
    echo "List routers"
    openstack \
        --os-cloud "${cloudname:?}" \
        router list

    echo "---- ----"
    echo "List networks"
    openstack \
        --os-cloud "${cloudname:?}" \
        network list

    echo "---- ----"
    echo "List subnets"
    openstack \
        --os-cloud "${cloudname:?}" \
        subnet list

    echo "---- ----"
    echo "List security groups"
    openstack \
        --os-cloud "${cloudname:?}" \
        security group list

    echo "---- ----"
    echo "List clusters"
    openstack \
        --os-cloud "${cloudname:?}" \
        coe cluster list

    echo "---- ----"
    echo "Done"




