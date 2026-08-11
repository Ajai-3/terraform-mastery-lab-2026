# AWS Elastic Beanstalk Blue-Green Deployment Demo ( Mini Project 4 )

## Covred Topics
- [](#)


# What is Blue-Green deployment staturgy ?

Instead of updating an active, live server directly, you run two identical production environments side-by-side:

Blue Environment: The current live production environment serving 100% of user traffic.

Green Environment: The idle clone environment where the new software version is deployed and tested privately.

So when new updates comes it will update the Green environment first and if its all working swap the Blue and Green environment make the Green as the Active environment

The 4 steps in Blue-Green environment

Deploy to Green: Send the new update to the idle Green environment (live users on Blue see no change).

Test Green: Run tests on Green to make sure the update works smoothly in isolation.

Swap Traffic: Flip your router or load balancer to redirect user traffic from Blue to Green.

Green is Live: Green becomes your active production environment, while Blue becomes the idle backup.

![alt.image](./image/architecture.png)