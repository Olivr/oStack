# oStack architecture decision

There are several options to build a reusable infrastructure stack.

First there is Terraform vs others like Pulumni. Terraform was chosen for 2 reasons:

1. It's the most popular, mature, and has the most integrations
2. It's using a declarative language

Indeed, I believe infrastructure should be as declarative as possible even though sometimes it hurts our inner DRYself. Alternatives like Pulumni are very powerful but their main advantage becomes their biggest enemy. Using a dynamic programming language would have made the creation and maintenance of oStack theoretically easier but in the long run the enemy would attack from two fronts: from within oStack and from how you extend oStack. The enemy I am talking about is "Spaghetti code".
