// Icons mapping
const jobIcons = {
    police: 'fa-shield-alt',
    ambulance: 'fa-ambulance',
    mechanic: 'fa-wrench',
    taxi: 'fa-taxi',
    unemployed: 'fa-user'
};

const licenseIcons = {
    idcard: 'fa-id-card',
    driver: 'fa-car',
    hunting: 'fa-gun',
    // weapon: 'fa-gun'
};

// Main container
const container = document.getElementById('container');

// Tab functionality
const tabs = document.querySelectorAll('.tab');
const contents = document.querySelectorAll('.content');

tabs.forEach(tab => {
    tab.addEventListener('click', () => {
        // Remove active class from all tabs and contents
        tabs.forEach(t => t.classList.remove('active'));
        contents.forEach(c => c.classList.remove('active'));

        // Add active class to clicked tab and corresponding content
        tab.classList.add('active');
        document.getElementById(`${tab.dataset.tab}Content`).classList.add('active');
    });
});

// Handle messages from the game client
window.addEventListener('message', function(event) {
    var data = event.data;
    
    if (data.type === "ui") {
        if (data.status) {
            container.style.display = "flex";
            if (data.jobs) populateJobs(data.jobs);
            populateLicenses(); // Always populate licenses when UI is shown
        } else {
            container.style.display = "none";
        }
    }
});

// Populate jobs in the menu
function populateJobs(jobs) {
    const jobList = document.getElementById('jobList');
    jobList.innerHTML = ''; // Clear existing jobs

    jobs.forEach(job => {
        const jobCard = document.createElement('div');
        jobCard.className = 'job-card';
        jobCard.onclick = () => selectJob(job.name);

        const icon = jobIcons[job.name] || 'fa-briefcase';
        
        jobCard.innerHTML = `
            <i class="fas ${icon}"></i>
            <h3>${job.label}</h3>
            <p>${job.description}</p>
        `;

        jobList.appendChild(jobCard);
    });
}

// Populate licenses in the menu
function populateLicenses() {
    const licenseList = document.getElementById('licenseList');
    licenseList.innerHTML = ''; // Clear existing licenses

    const licenses = [
        { name: 'id_card', label: 'ID Card', description: 'Official identification document' },
        { name: 'driver_license', label: 'Driver\'s License', description: 'Required for operating vehicles' },
        { name: 'hunting_license', label: 'Hunting License', description: 'Permit for hunting activities' },
        // { name: 'weaponlicense', label: 'Weapon License', description: 'Authorization to carry firearms' }
    ];

    licenses.forEach(license => {
        const licenseCard = document.createElement('div');
        licenseCard.className = 'license-card';
        licenseCard.onclick = () => selectLicense(license.name);

        const icon = licenseIcons[license.name] || 'fa-certificate';
        
        licenseCard.innerHTML = `
            <i class="fas ${icon}"></i>
            <h3>${license.label}</h3>
            <p>${license.description}</p>
        `;

        licenseList.appendChild(licenseCard);
    });
}

// Handle job selection
function selectJob(jobName) {
    fetch(`https://${GetParentResourceName()}/jobSelected`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            job: jobName
        })
    });
}

// Handle license selection
function selectLicense(licenseName) {
    fetch(`https://${GetParentResourceName()}/licenseSelected`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            license: licenseName
        })
    });
}

// Close button handler
document.getElementById('closeButton').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/exit`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
});

// Close on escape key
document.addEventListener('keyup', function(event) {
    if (event.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/exit`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        });
    }
});