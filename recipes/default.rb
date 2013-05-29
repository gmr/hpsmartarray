#
# Cookbook Name:: hpsmartarray
# Recipe:: default
#
# Copyright 2013, MeetMe, Inc.
#
# All rights reserved - Do Not Redistribute
#
package 'hpacucli' do
  action :install
end

def get_controllers()
  output = `hpacucli controller all show`
  slots = output.scan(/in Slot\s+(?<slot>\d+)\s/).flatten.select{ |slot| slot if slot != '0' }
end

def get_drives()
  controllers = get_controllers()
  drives = Hash.new(controllers)
  controllers.each do |slot|
    output = `hpacucli controller slot=#{slot} physicaldrive all show`
    drives[slot] = output.scan(/physicaldrive (\d[A-F]\:\d+\:\d+)/).flatten.sort
  end
  drives
end

def create_logical_drive(slot, drive_list)
  standby_drive = drive_list[0]
  temp = standby_drive.split(':')
  temp[2] = temp[2].to_i + 1
  start_drive = temp.join(':')
  temp[2] = drive_list.length
  end_drive = temp.join(':')
  output = `hpacucli ctrl slot=#{slot} create type=ld raid=1+0 drives=#{start_drive}-#{end_drive}`
  print(output)
  output = `hpacucli ctrl slot=#{slot} array A add spares=#{standby_drive}`
  print(output)
end

#drives = get_drives()
#drives.each do |slot, drive_list|
#  create_logical_drive(slot, drive_list)
#end
