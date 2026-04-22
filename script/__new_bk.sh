#!/bin/bash

mount_p="$(mount | grep bk | awk '{print $3}')"
if 
