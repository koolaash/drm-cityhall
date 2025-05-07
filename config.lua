Config = {}

-- Change to your current framework "esxold" "legacy" "newqb" "oldqb"
Config.Framework = 'newqb'   

-- Job center location
Config.Location = vector3(-264.17, -965.45, 31.22)

-- Config for the target options
Config.TargetPeds = {
    {
        model = 'a_m_m_hasjew_01',
        coords = Config.Location,
        heading = 210.0,
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        label = 'Speak to Clerk',
        icon = 'fas fa-id-card',
        distance = 2.5
    }
}

-- Available jobs
Config.Jobs = {
    {
        name = "police",
        label = "Police Officer",
        description = "Protect and serve the city"
    },
    {
        name = "ambulance",
        label = "Emergency Medical Services",
        description = "Save lives and provide medical care"
    },
    {
        name = "mechanic",
        label = "Auto Mechanic",
        description = "Repair and maintain vehicles"
    },
    {
        name = "taxi",
        label = "Taxi Driver",
        description = "Transport citizens around the city"
    },
    {
        name = "unemployed",
        label = "Unemployed",
        description = "No current occupation"
    }
}

Config.License = {
    {
        type = "id_card",  
        itemName = 'id_card',
        label = 'ID Card',
    },
    {
        type = "driver_license",  
        itemName = 'driver_license',
        label = 'Driver\'s License',
    },
    {
        type = "hunting_license",  
        itemName = 'hunting_license',
        label = 'Hunting License',
    },
    {
        type = "weapon_license",  
        itemName = 'weapon_license',
        label = 'Firearm License',
    }
}