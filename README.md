# Hello World Project

A Website simplifying pre-trip planning, records user on-trip journey and reminisce post-trip itineraries.

## #1: Backend MVP 

**Ensure that the minimum viable product proof is done first**

<details>
  <summary>Read more</summary>
  
  #### MVP List (Proof of work)
  1. Plan user journey
  2. Plan Schema
  3. Setup Rails framework
  4. Setup test and production server host
  5. Create routes based on Schema
  6. Setup login feature
  7. user can create itinerary
  8. user can access map and add places of interest into their itinerary
  9. user itineraries can be saved and viewed
  10. user can browse other people itineraries
  11. User can copy other people itineraries as their own
  
</details>


## #2: Basic CSS 

**Use figma for UI/UX design and apply css styling for 1st interim presentation**


## #3: Additional features

**Upon MVP approval, work on next important features**

<details>
  <summary>Read more</summary>
  
  #### Features added
  1. add navbar
  2. Itinerary phase type included (in-plan, ongoing, require review, completed) 
  3. map able to show shortest route
  4. user can see additonal information for each actvity on the map with double click
  4. itinerary activities can be rearranged
  5. booking checklist for locations that requires booking
  6. personal checklist for user to add/remove/checked
  5. user can add images and reviews for each actvity while on ongoing trip
  6. user can share overall trip review, recommendation, pros and cons
  7. Completed phase itineraries will cycle through images taken by user, to reminisce
  
</details>


## #4: Clean up CSS

**Focus on finalising CSS styling and animations**


## #5: Review and patch codes 

**Check for bugs**


## #6: Presentation

**focus on preparing for presentation**


#SQL FUNCTIONS

 

def save_json_into_db():
#     c.execute('''DROP TABLE devices ''')

#     # try creating table device
#     c.execute('''CREATE TABLE devices (
#         device_id INT NOT NULL,
#         device_name VARCHAR(255) NOT NULL,
#         device_status VARCHAR(255) NOT NULL,
#         device_lat VARCHAR(100) NOT NULL,
#         device_lon VARCHAR(100) NOT NULL,
#         fw_ver VARCHAR(100) NOT NULL,
#         PRIMARY KEY ( device_id )
#         )''')

    c.execute(''' DESCRIBE devices''')
    r = c.fetchall()
    print (r)

    # retrieve all devices' information
    devices_info = request_api('https://api.ic.peplink.com/rest/o/92awyy/d?', saved_access_token)
    # print (devices_info) 
    print (len(devices_info['data']))
    devices_data = devices_info['data']

 

    for d in devices_data:
        # get index position for other api calling
        print (devices_data.index(d))

        # pull current location
        cur_loc = request_api('https://api.ic.peplink.com/rest/o/92awyy/g/1/d/'+ str(d['id']) + '/loc?', saved_access_token)
        loc_data = cur_loc['data']
        print (cur_loc)
        print (loc_data)
        print (loc_data[0]['la'])

        # select device_id from devices
        # if device_id exist .... do update ....
#         db.execute("SELECT id2 from my_table where id = '%s';" % user)


        c.execute('''INSERT INTO devices (device_id, device_name, device_status, device_lat, device_lon, fw_ver)
        VALUES (%s, %s, %s, %s, %s, %s)''', (d['id'], d['name'], d['status'], loc_data[0]['la'], loc_data[0]['lo'], d['fw_ver']))


 

save_json_into_db()

 

# check if insert data is successful
c.execute(''' SELECT * FROM devices ''') 
r = c.fetchall()
print ('start check', r)

 

# check tables using pandas
devices_table = pd.read_sql('SELECT * FROM devices', con)
display(devices_table)

