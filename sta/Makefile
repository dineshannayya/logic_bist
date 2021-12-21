# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

#BLOCKS = glbl_cfg wb_interconnect mbist1 mbist2 wb_host user_project_wrapper
BLOCKS = user_project_wrapper
DEF = $(foreach block,$(BLOCKS), ../def/$(block).def)
CLEAN = $(foreach block,$(BLOCKS), clean-$(block))

OPENLANE_TAG ?= mpw3
OPENLANE_IMAGE_NAME ?= dineshannayya/openlane:$(OPENLANE_TAG)
OPENLANE_STA_COMMAND = "cd /project/sta && sta scripts/sta.tcl | tee logs/sta.log"

all: $(BLOCKS)

$(DEF) :
	@echo "Missing $@. Please create a def for that design"
	@exit 1

$(BLOCKS) : % : ../def/%.def  create 
	mkdir -p reports/$@/func
	mkdir -p reports/$@/scan
	@echo "Design: $@ : Running Functional mode STA"
	docker run -it  -v $(PWD)/..:/project -e DESIGN_NAME=$@ -e STA_MODE=func -v ${PDK_ROOT}:${PDK_ROOT} -e PDK_ROOT=${PDK_ROOT} -u $(shell id -u $(USER)):$(shell id -g $(USER)) $(OPENLANE_IMAGE_NAME) sh -c $(OPENLANE_STA_COMMAND)
	@echo "Design: $@ : Running Scan mode STA"
	docker run -it  -v $(PWD)/..:/project -e DESIGN_NAME=$@ -e STA_MODE=scan -v ${PDK_ROOT}:${PDK_ROOT} -e PDK_ROOT=${PDK_ROOT} -u $(shell id -u $(USER)):$(shell id -g $(USER)) $(OPENLANE_IMAGE_NAME) sh -c $(OPENLANE_STA_COMMAND)

create: clean
	@echo "create temp directory :)"
	mkdir -p netlist
	mkdir -p logs
	mkdir -p reports

clean:
	@echo "clean everything :)"
	rm -rf netlist
	rm -rf logs
	rm -rf reports

