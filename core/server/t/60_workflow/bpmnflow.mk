# Run bpmnflow
#
# Usage:
#
#   cd ~/git/openxpki
#   make clean -f core/server/t/60_workflow/bpmnflow.mk
#   make -f core/server/t/60_workflow/bpmnflow.mk
#   

FULLPERLRUN := $(shell which perl)

# Base directory containing test script and config dir
basedir := core/server/t/60_workflow

# Destination directory for the workflow XML files
xmldir := $(basedir)/bpmnflow.d

bpmndir := core/config/bpmn
bpmnflow := tools/scripts/bpmnflow.pl

workflows := bpmnflow

# Determine names of four individual workflow XML files
basenames := $(foreach file,$(workflows),workflow_def_$(file) workflow_activity_$(file) workflow_condition_$(file))

# Prepend the full file path of the host-specific files and add .xml extension
xmls := $(foreach file,$(basenames),$(xmldir)/$(file).xml)

all: $(xmls)

clean: 
	rm -f $(xmls)

# Create the XML files

$(xmldir)/workflow_def_%.xml: $(bpmndir)/workflow_%.bpmn $(bpmnflow)
	$(bpmnflow) --outtype=states --outfile="$@" --infile="$<"

$(xmldir)/workflow_activity_%.xml: $(bpmndir)/workflow_%.bpmn $(bpmnflow)
	$(bpmnflow) --outtype=actions --outfile="$@" --infile="$<"

$(xmldir)/workflow_condition_%.xml: $(bpmndir)/workflow_%.bpmn $(bpmnflow)
	$(bpmnflow) --outtype=conditions --outfile="$@" --infile="$<"
