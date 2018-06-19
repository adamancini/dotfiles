# support dump reconsituters

# extract latest support dump to a dated directory and cd into it
# nuke useless dsinfo subdirs
splode ()
{
    CAPDIR_PREFIX="sd";
    SUPPORT_DUMP_PAT='docker-support*zip';
    if [ -z $1 ]; then
        source=$(ls -rt $SUPPORT_DUMP_PAT |tail -n1);
    else
        source=$1;
    fi;
    capdate=$(echo $source |cut -d- -f3- |sed 's:.zip$::');
    capdir=${CAPDIR_PREFIX}${capdate};
    mkdir $capdir;
    cd $capdir;
    ln -s ../$source .;
    unzip -qq *zip;
    for dir in */;
    do
        mv $dir/dsinfo/* $dir;
        rmdir $dir/dsinfo;
    done;
    ls -l
}

# NOTE: remainder of functions presume the useless $node/dsinfo/ dir has had
# its contents moved to $node/

# enhanced `docker node ls` from root of support dump
sd_nodes() {
    (echo HOSTNAME ID ROLE ARCH OS AVAIL STATE IP DAEMON COLLECT ORCHESTR STATUS_MESSAGE
        jq '.[] |
            [(.Description.Hostname // "none"),
                .ID[0:10],
                (if .ManagerStatus.Leader == true then
                    "leader"
                else
                    .Spec.Role
                end),
                .Description.Platform.Architecture,
                .Description.Platform.OS,
                .Spec.Availability,
                .Status.State,
                (if .Status.Addr == "127.0.0.1" or .Status.Addr == "0.0.0.0" then
                    .ManagerStatus.Addr
                else
                    .Status.Addr
                end),
                .Description.Engine.EngineVersion,
                .Spec.Labels."com.docker.ucp.access.label",
                (if .Spec.Labels."com.docker.ucp.orchestrator.swarm" == "true" and
                    .Spec.Labels."com.docker.ucp.orchestrator.kubernetes" == "true" then
                    "swarm/kube"
                elif .Spec.Labels."com.docker.ucp.orchestrator.swarm" == "true" then
                    "swarm"
                elif .Spec.Labels."com.docker.ucp.orchestrator.kubernetes" == "true" then
                    "kube"
                else
                    "-"
                end),
                (.Status.Message | gsub(" "; "_"))]
            |@tsv' -r ucp-nodes.txt | sed 's/:2377//' \
                | awk '{
                    if(system("! [ `find " $1 " -name \"dtr-registry*txt\"` ]"))
                        {$3 = $3 "/DTR"}
                    print
                }' \
                | sort -k3,5 -k1,1V -s
    ) | column -t \
      | sed '1{p;s/./-/g}'
}

# prints beginning and end of daemon logs. run from root of supportdumpc
sd_logspan() {
    for file in */journal*; do
        echo -n $file": "$(head -n3 $file |tail -n1 |cut -d' ' -f1-3)" -- "$(tail -n1 $file |cut -d ' ' -f1-3) $(grep -q level=debug $file && echo "(debug)")
        echo
    done | sort -t/ -k1,1 -s | column -t
}

# agent logs from the running ucp-agent task:
# expects to run from the host's directory
sd_agent_logs(){
    cat $(jq -r '.[]|select(.State.Status=="running")|input_filename|sub("inspect";"logs")|sub("txt";"log")' inspect/ucp-agent*)
}


# container health checks from managers
