import sys
import boto3
import json
import uuid
from decimal import Decimal

tablename = sys.argv[1]
region = sys.argv[2]
ddb = boto3.resource('dynamodb', region_name=region)

table = ddb.Table(tablename)
response = table.scan(
	Select='ALL_ATTRIBUTES',
	Limit=1
)

if len(response['Items']):
	print('Already loaded!')
	sys.exit()

response = table.put_item(
	Item={
		'ProductId': 'BE0001',
		'ProductName': 'Chemex Classic 6 cup Coffeemaker',
		'Price': Decimal('49.99'),
		'Discount': 0,
		'Manufacturer': 'Chemex',
		'Cost': Decimal('35.5'),
		'Image': 'BE0001.jpg',
		'Description': '<p>Simple function and visual elegance combine for the optimum extraction of full rich-bodied coffee. The Chemex Classic Series coffeemaker is both elegant and versatile.</p><ul><li>6 cup, 30 ounce size (Please note: Coffeemakers are measured using 5 oz. as 1 cup.)</li><li>Includes a polished wood collar with leather tie.</li></ul>',
		'Taxable': True,
		'Weight': Decimal('3.35'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Brewing Equipment","Pour Over"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'BE0002',
		'ProductName': 'Chemex Prefolded Filter Squares, Natural',
		'Price': Decimal('12.99'),
		'Discount': 0,
		'Manufacturer': 'Chemex',
		'Cost': Decimal('9.3'),
		'Image': 'BE0002.jpg',
		'Description': '<p>Chemex filters are 20-30% heavier than competitive brands and remove even the finest sediment particles as well as the undesirable oils and fats. The formulation of the filter permits the proper infusion time by regulating the filtration rate not too slow, not too fast. Good infusion of the coffee grounds (as in brewing and steeping tea) gives coffee a richer flavor while at the same time making possible precise fractional extraction filtering out the undesirable components which make coffee bitter by allowing only the desirable flavor elements of the coffee bean to pass through.</p><p>The Chemex filter is folded into a cone shape, exactly as in laboratory techniques. This assures uniform extraction since the water filters through all the grounds on its way to the apex of the cone. The Chemex filter is guaranteed not to burst under the weight of the liquid during filtration, and not to break when lifting out the grounds.</p>',
		'Taxable': True,
		'Weight': Decimal('1.3'),
		'Unit': 'set',
		'Count': 100,
		'Categories': '["Brewing Equipment","Filters"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'BE0003',
		'ProductName': 'Kalita, Wave Glass Server',
		'Price': Decimal('17.99'),
		'Discount': 0,
		'Manufacturer': 'Kalita',
		'Cost': Decimal('12.85'),
		'Image': 'BE0003.jpg',
		'Description': '<p>The Kalita glass server is a beautiful Coffee or tea server made from straight-sided, heat-resistant, tempered glass. Keep it warm on the stove or set it on the table to serve immediately. Each server comes with a molded plastic lid to keep the Coffee hotter, longer. Kaila glass servers are durable and dishwasher safe.</p>',
		'Taxable': True,
		'Weight': Decimal('1'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Brewing Equipment","Pour Over"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'BE0004',
		'ProductName': 'Kalita Wave 185 Drippers',
		'Price': Decimal('22.99'),
		'Discount': 0,
		'Manufacturer': 'Kalita',
		'Cost': Decimal('16.4'),
		'Image': 'BE0004.jpg',
		'Description': '<p>This glass Kalita Wave 185 dripper is ideal for brewing 16-26 oz of flavorful, full-bodied coffee. Designed with a flat-bottomed coffee bed, three small extraction holes, and a patented wave filter, the Kalita Wave dripper pulls a rich, evenly extracted cup. Also available in stainless steel and ceramic. Kalita 185 filters are available separately.</p>',
		'Taxable': True,
		'Weight': Decimal('0.5'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Brewing Equipment","Pour Over"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'BE0005',
		'ProductName': 'Bodum Chambord 12 Cup French Press',
		'Price': Decimal('49.99'),
		'Discount': 0,
		'Manufacturer': 'Bodum',
		'Cost': Decimal('35.5'),
		'Image': 'BE0005.jpg',
		'Description': '<p>When Bodum took over a small clarinet factory in Normandy in 1982, it was not because of the fine orchestra clarinets they were producing but because of a relatively unknown coffee maker called the Chambord which they produced as well. The reason the French press coffee maker has become one of the most popular coffeemakers in the world is pure and simple, taste. The materials (glass and stainless steel) are completely taste-free so nothing comes between your ground coffee beans. This is exactly the reason why coffee tasters use this method to determine the quality of coffee beans. No paper filter not only means no waste, but that the coffee bean\'s essential oils go directly to your cup, delivering the flavor that is lost on paper filters. Simplicity works best and is the reason why the Chambord\'s design has not changed a bit from its original drawing. Make taste, not waste! 1.5 l, 51 oz capacity.</p>',
		'Taxable': True,
		'Weight': Decimal('1.8'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Brewing Equipment","French Presses"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'BE0006',
		'ProductName': 'Fellow, Stagg XF Pour-Over Filters',
		'Price': Decimal('8.99'),
		'Discount': 0,
		'Manufacturer': 'Fellow',
		'Cost': Decimal('6.4'),
		'Image': 'BE0006.jpg',
		'Description': '<p>Paper filters designed specifically for Fellow XS drippers steep slopes.</p><ul><li>45 in each pack</li><li>flat bottom design</li></ul>',
		'Taxable': True,
		'Weight': Decimal('0.5'),
		'Unit': 'set',
		'Count': 50,
		'Categories': '["Brewing Equipment","Filters"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'BE0007',
		'ProductName': 'Fetco GR 2.3 Coffee Grinder',
		'Price': Decimal('1999'),
		'Discount': 0,
		'Manufacturer': 'Fetco',
		'Cost': Decimal('1425'),
		'Image': 'BE0007.jpg',
		'Description': '<p>The GR-2.3 dual hopper coffee grinder is portion controlled so you grind only the amount you need. Choose from three different batch sizes with the touch of a button. This unit\'s powerful .74 Hp motor and precision slice grinding discs help deliver uniform grind profiles every time.</p>',
		'Taxable': True,
		'Weight': Decimal('70'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Brewing Equipment","Grinders"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'BE0008',
		'ProductName': 'Hario V60 Ceramic Coffee Dripper',
		'Price': Decimal('19.99'),
		'Discount': 0,
		'Manufacturer': 'Hario',
		'Cost': Decimal('14'),
		'Image': 'BE0008.jpg',
		'Description': '<p>Designed for manual, pour-over style coffee brewing. Brews one to three cups at a time. Works well with V60 size 02 paper or cloth filters. Very hands-on brewing, allowing you, the user, to control brewing time and temperature. Ceramic body is durable and helps prevent heat loss during the brewing cycle.</p>',
		'Taxable': True,
		'Weight': Decimal('1'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Brewing Equipment","Pour Over"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'BE0009',
		'ProductName': 'Fetco GR-1.3 Single Hopper Commercial Coffee Grinder',
		'Price': Decimal('1140'),
		'Discount': 0,
		'Manufacturer': 'Fetco',
		'Cost': Decimal('810'),
		'Image': 'BE0009.jpg',
		'Description': '<p>Equipped with a large 15 lb single hopper, the GR 1.3 not only keeps an impressive amount of beans fresh and ready to go, but also can grind up to three batch sizes with just the touch of a button. With the ability to grind small, medium and large batches, this machine is also portion controlled so you only grind the exact amount you need.</p><p>The GR 1.3 runs with a powerful .5 horsepower motor and precision slice grinding discs in order produce consistent and even grind results with every use. Additionally, this grinder is designed to grind directly into the brew basket for increased efficiency.</p>',
		'Taxable': True,
		'Weight': Decimal('57'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Brewing Equipment","Grinders"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'BE0010',
		'ProductName': 'Fetco Tea Brewer',
		'Price': Decimal('1750'),
		'Discount': 0,
		'Manufacturer': 'Fetco',
		'Cost': Decimal('1250'),
		'Image': 'BE0010.jpg',
		'Description': '<p>The TBS-2121XTS Tea Brewer by Fetco is expertly crafted with modern brewing technology for a convenient and intuitive brewing experience. The twin 3.5 gallon brewer incorporates contemporary style and functionality with the touch screen display, dual dilution spouts and sleek, space saving design. Simply use the touchscreen with its friendly interface to program recipes, control brewing functions, run diagnostics and save valuable data. Additionally you can customize your display with up to nine recipes. For convenience, the brewer\'s side sensors automatically detect from what side brewing will occur and displays the matching recipes on the touchscreen.</p><p>Perfect for serving clients, customers and colleagues at an office, conference center, showroom or shop, the slimly designed tea dispenser takes up minimal counter space and produces flavorful and refreshing beverages that everyone will enjoy.</p>',
		'Taxable': True,
		'Weight': Decimal('35'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Brewing Equipment","Tea Brewers"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'BT0011',
		'ProductName': 'Rhino Coffee Gear Shot Glass-Double',
		'Price': Decimal('11.99'),
		'Discount': 0,
		'Manufacturer': 'Rhino Coffee Gear',
		'Cost': Decimal('8.5'),
		'Image': 'BT0011.jpg',
		'Description': '<p>Rhino wares has answered the call for a double-spouted shot glass that combines durability and functionality.  This 80ml (3 Ounce) handled shot glass is perfect for pulling Double shots.  The handle protects fingers from the heat of a freshly dropped shot.  Graduated measurement marks make it so easy to get the shot right.</p>',
		'Taxable': True,
		'Weight': Decimal('0.5'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Barista Tools","Shot Glasses"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'BT0012',
		'ProductName': 'Krome Wooden Barista Style Coffee Knock Box',
		'Price': Decimal('82.99'),
		'Discount': 0,
		'Manufacturer': 'Krome Dispense',
		'Cost': Decimal('59'),
		'Image': 'BT0012.jpg',
		'Description': '<p>Krome Dispense Wooden Counter Top Knock Box combines stylish design and minimalism with easy handling and cleaning. Solidly constructed from wood and will stand the test of time. Wood body is durable and looks great on the countertop.</p>',
		'Taxable': True,
		'Weight': Decimal('9'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Barista Tools","Knock Boxes"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'BT0013',
		'ProductName': 'Stainless Steel Espresso Tamper - Handle Solid Wood',
		'Price': Decimal('19.99'),
		'Discount': 0,
		'Manufacturer': 'VD Coffee',
		'Cost': Decimal('14'),
		'Image': 'BT0013.jpg',
		'Description': '<p>Manual production and the highest quality control in production, allows us to make a unique hand tamper with an excellent balance between weight and size, to help you form the most correct "coffee puck" so that you can enjoy the stunning taste and aroma of freshly brewed coffee.</p><p>Features and Benefits: <ul><li>Espresso tamper tool is made of high-quality non-wrought steel Aisi 304.</li><li>The handle of the coffee barista tamper is made of high quality, durable and durable valuable wood.</li><li>The handle in the steel espresso tamper has a special ergonomic design that is suitable for any size and shape of hands.</li><li>Coffee tamper pressure has a unique balance between weight and size, for better compression of coffee.</li><li>Our espresso tamps perfectly resists damage caused by natural acids contained in coffee and is not susceptible to rust.</li><li>Coffee temper accessories are easy to clean with a sponge and teal water.</li></ul></p>',
		'Taxable': True,
		'Weight': Decimal('1'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Barista Tools","Tampers"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'BT0014',
		'ProductName': 'Rattleware 24-Ounce Aluminum Scoop',
		'Price': Decimal('21.99'),
		'Discount': 0,
		'Manufacturer': 'Rattleware',
		'Cost': Decimal('15'),
		'Image': 'BT0014.jpg',
		'Description': '<p><ul><li>Lightweight</li><li>Perfect for scooping ice or bulk beans</li></ul></p>',
		'Taxable': True,
		'Weight': Decimal('0.5'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Barista Tools","Scoops"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'BT0015',
		'ProductName': 'Rattleware 5-Inch Easy Steam Thermometer',
		'Price': Decimal('16.99'),
		'Discount': 0,
		'Manufacturer': 'Rattleware',
		'Cost': Decimal('12'),
		'Image': 'BT0015.jpg',
		'Description': '<p>This thermometer reads in both fahrenheit and celsius. Features a turn off point indicator, calibration points and red and green zones.</p><ul><li>Dimensions: 1.6" wide x 2" long x 6.4" tall</li><li>The green zone signifies perfectly steamed milk</li><li>The red indicates burned milk</li><li>Comes with an NSF thermometer clip and calibration instructions on the sleeve</li><li>NSF approved</li></ul>',
		'Taxable': True,
		'Weight': Decimal('0.5'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Barista Tools","Thermometers"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'EM0016',
		'ProductName': 'Nuova Simonelli, Aurelia II 2 Group',
		'Price': Decimal('10199'),
		'Discount': 0,
		'Manufacturer': 'Nuova Simonelli',
		'Cost': Decimal('7285'),
		'Image': 'EM0016.jpg',
		'Description': '<p>The Aurelia II line has been designed with all the most important factors in mind: the barista, the customer and the owner all get the best possible experience. Nuova Simonelli machines are known for their durability, their precision and since the Aurelia II, their incredible list of features</p>',
		'Taxable': True,
		'Weight': Decimal('142'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Espresso Machines","2 Group"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'EM0017',
		'ProductName': 'Nuova Simonelli MDX On-Demand Electronic Espresso Grinder 65mm Burrs Black',
		'Price': Decimal('1599'),
		'Discount': 0,
		'Manufacturer': 'Nuova Simonelli',
		'Cost': Decimal('1140'),
		'Image': 'EM0017.jpg',
		'Description': '<p>The MDX On-Demand is one of our most popular on-demand grinders. Perfect for medium size shops, this grinder can quickly and accurately dose high-quality shots in a matter of seconds. A feature that will be appreciated in any shop especially when combined with the ability to program dosages. If you\'re looking to improve consistency and efficiency this might just be the machine for you</p>',
		'Taxable': True,
		'Weight': Decimal('50'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Espresso Machines","Grinders"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'EM0018',
		'ProductName': 'Eversys e`2 Super Automatic Espresso Machine',
		'Price': Decimal('16499'),
		'Discount': 0,
		'Manufacturer': 'Eversys',
		'Cost': Decimal('11785'),
		'Image': 'EM0018.jpg',
		'Description': '<p>The Eversys e`2 is a superautomatic, commercial grade espresso machine with a futuristic look that\'s equipped with all the cutting edge technology you could hope for in a modern machine. This state-of-the art model is uniquely designed in a modular format with separate modules for each of its different functions: grinding, brewing, steaming, and milk. This separate modular design makes servicing the machine easier, faster, and more efficient. On the front of the E2 you will find a large 8" touch screen complete with icons and images for conveniently programming and saving your beverage recipes, as well as controlling the machine\'s other functions. Easily customize the touch screen to your business needs with different images and workflows.</p>',
		'Taxable': True,
		'Weight': Decimal('150'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Espresso Machines","1 Group","Super Automatic"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'EM0019',
		'ProductName': 'Rocket R NINE ONE Espresso Machine',
		'Price': Decimal('6850'),
		'Discount': 0,
		'Manufacturer': 'Rocket Espresso Milano',
		'Cost': Decimal('4890'),
		'Image': 'EM0019.jpg',
		'Description': '<p>Crafted with the utmost quality in mind, this brand new espresso maker by Rocket combines state of the art design elements with modern technology and stunning, classic style to create a truly impressive machine. The R9 One is a semi-automatic machine built with durable stainless steel framing and paneling and sits on sleek, Appartamento style feet. For programming and controlling daily operations, the R9 One features a vivid, touchscreen display as well as two analog boiler group gauges for monitoring brew and steam pressure. This Espresso maker also includes a cup warmer, a stainless steel hot water spigot, and a stainless steel steam arm with a two hole steam tip for your milk based beverages. For versatility, you can choose between utilizing the R9 One\'s 67 oz water reservoir, or you can plumb the unit directly into your water line, which eliminates refilling and also gives you the ability to use inline water filtration options.</p>',
		'Taxable': True,
		'Weight': Decimal('105'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Espresso Machines","1 Group"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'EM0020',
		'ProductName': 'K30 Twin Espresso Grinder by Mahlkonig',
		'Price': Decimal('3250'),
		'Discount': 0,
		'Manufacturer': 'Mahlkonig',
		'Cost': Decimal('2320'),
		'Image': 'EM0020.jpg',
		'Description': '<p>Mahlkonig knows how to make a perfect electronically operated grinder. The K30 Twin Espresso Grinder is one of their absolute best, especially with its expertise of "grind on demand". Easy to use, very quiet, and keeps your coffee nice and fresh without losing your aroma.</p>',
		'Taxable': True,
		'Weight': Decimal('58'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Espresso Machines","Grinders"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'KA0021',
		'ProductName': 'Vitamix Professional Series 750 Blender, Professional-Grade, 64 oz. Low-Profile Container, Black',
		'Price': Decimal('599.99'),
		'Discount': 0,
		'Manufacturer': 'Vitamix',
		'Cost': Decimal('425'),
		'Image': 'KA0021.jpg',
		'Description': '<p>Perfect for front-of-the-house operations, the Blending Station Advance is the A-lister\'s dream. With 93 variable speeds, an automatic shut-off, and 34 optimized programs, no machine will work harder during peak hours of operation.</p>',
		'Taxable': True,
		'Weight': Decimal('17.2'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Kitchen Appliances","Blenders"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'KA0022',
		'ProductName': 'Breville Die-Cast 4-Slice Smart Toaster',
		'Price': Decimal('179.99'),
		'Discount': 0,
		'Manufacturer': 'Breville',
		'Cost': Decimal('130'),
		'Image': 'KA0022.jpg',
		'Description': '<p>The Breville 4 Slice Smart Toaster has an internal smart chip that lowers bread into the toasting slots with a single touch and also regulates the toasting time. On the "a bit more" setting bread is automatically lowered for additional toasting time. The auto lift and look feature automatically raises the bread carriage during toasting without canceling or resetting the cycle. This enables you to view, and if necessary, cancel the browning cycle at any time. The LED panel illuminates according to the selected setting on the variable browning control. The display acts as a toasting progress indicator, counting down how long is left in the toasting cycle. The toaster beeps when the cycle is complete. Made of brushed die-cast metal the exterior wipes clean with a soft cloth.</p>',
		'Taxable': True,
		'Weight': Decimal('11.6'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Kitchen Appliances","Toasters"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'KA0023',
		'ProductName': 'Breville Panini Duo 1500-Watt Nonstick Panini Press',
		'Price': Decimal('69.99'),
		'Discount': 0,
		'Manufacturer': 'Breville',
		'Cost': Decimal('50'),
		'Image': 'KA0023.jpg',
		'Description': '<p>In keeping with its heritage of creating the world\'s first domestic version of a professional sandwich press, Breville introduces the Panini Duo . With a 1500-watt heating element that heats up quickly, the Panini Duo\'s top plate delivers beautiful grill marks on any kind of bread, while its bottom plate delivers even and quicker heat on the flat to make the perfect Panini or your own toasted sandwich creation. Grill surfaces are made with a non-stick, scratch-proof Quantanium surface for easy cleaning. With its sturdy construction and stainless steel construction, the Panini Duo delivers on Breville\'s promise of performance and elegance.</p>',
		'Taxable': True,
		'Weight': Decimal('9.25'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Kitchen Appliances","Paninis and Grills"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'KA0024',
		'ProductName': 'Vevor Commercial Maker Machine',
		'Price': Decimal('499.99'),
		'Discount': 0,
		'Manufacturer': 'Vevor',
		'Cost': Decimal('355'),
		'Image': 'KA0024.jpg',
		'Description': '<p>Our Commercial Ice Maker equipped with digital control panel and owns the ability to set time of making ice in advance. Reservation setting is available up to 5 hours. You can expect for nice and comfortable sleep in the evening. Digital control panel shows the problem when machine stops making ice and offer reminds when ice is full. Cleaning is also easy to be done with a simple push at the button.</p>',
		'Taxable': True,
		'Weight': Decimal('58'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Kitchen Appliances","Ice Makers"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'KA0025',
		'ProductName': 'Sharp Medium Duty Commercial Microwave',
		'Price': Decimal('359.99'),
		'Discount': 0,
		'Manufacturer': 'Sharp',
		'Cost': Decimal('250'),
		'Image': 'KA0025.jpg',
		'Description': '<p>Sharp is dedicated to improving people\'s lives through the use of advanced technology and a commitment to innovation, quality, value, and design. The classic dial timer can be set anywhere from 10 seconds to 6 minutes and includes bright LED indicators that permits "at-a-glace" monitoring. The 1.0 cubic ft. capacity can accommodate a 13-1/2" platter, prepackaged foods, single servings or a half-size pan in either direction. When the door is opened during cooking, the remaining time is cancelled; saving energy and increasing the magnetron\'s life. Stainless steel exterior wrap and interior for easy cleaning and a commercial look. A handy "on-the-spot" reference for timesaving convenience is located above the timer with recommended times for heating a variety of popular foods.</p>',
		'Taxable': True,
		'Weight': Decimal('44'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Kitchen Appliances","Microwave Ovens"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'BE0026',
		'ProductName': 'Fetco Touchscreen Single Coffee Brewer',
		'Price': Decimal('1550'),
		'Discount': 0,
		'Manufacturer': 'Fetco',
		'Cost': Decimal('1100'),
		'Image': 'BE0026.jpg',
		'Description': '<p>The Single Station 1.0 Gallon CBS-2141XTS Touchscreen Series Coffee Brewer provides flexibility in small-to-medium sized venues such as Convenience Stores, Bakery Cafes and Lobbies. You can now experience total control of this fully featured Extractor Brewing System via an inviting touchscreen interface display that is intuitive, easy to read and simple to navigate.</p>',
		'Taxable': True,
		'Weight': Decimal('47'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Brewing Equipment","Coffee Brewers"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'BE0027',
		'ProductName': 'Fetco Touchscreen Double Coffee Brewer',
		'Price': Decimal('2085'),
		'Discount': 0,
		'Manufacturer': 'Fetco',
		'Cost': Decimal('1485'),
		'Image': 'BE0027.jpg',
		'Description': '<p>The Twin Station 1.0 Gallon CBS-2142XTS Touchscreen Series Coffee Brewer provides flexibility in small-to-medium sized venues such as Convenience Stores, Bakery Cafes and Lobbies. You can now experience total control of this fully featured Extractor Brewing System via an inviting touchscreen interface display that is intuitive, easy to read and simple to navigate.</p>',
		'Taxable': True,
		'Weight': Decimal('85'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Brewing Equipment","Coffee Brewers"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'BE0028',
		'ProductName': '3.0L Pump Lever Airpot',
		'Price': Decimal('89.99'),
		'Discount': 0,
		'Manufacturer': 'Fetco',
		'Cost': Decimal('65'),
		'Image': 'BE0028.jpg',
		'Description': '<p>The 3.0L pump lever airpot is an economical, convenient and safe solution for light duty self-serve beverage dispensing. Constructed of dual layer stainless steel, the vacuum sealed inner liner insulates and holds the beverage while the outer body layer protects the end user by staying cool to the touch. The locking lid is designed to swing open fully for brewing directly into the airpot funnel for ease of filling with the secondary benefit of maximum heat retention. The pump lever dispensing system is simple to use and allows the end user to precisely control the amount of liquid poured into their cup without lifting, holding or tilting the airpot. A swivel carry handle helps make the airpot extremely portable for coffee service virtually anywhere and its small footprint allows for multiple flavor offerings in a limited amount of table or counter space. It also features a rotating base for multi-directional cup filling!</p>',
		'Taxable': True,
		'Weight': Decimal('30'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Brewing Equipment","Airpots"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'BE0029',
		'ProductName': 'BUNN 12-Cup Pourover Commercial Coffee Brewer',
		'Price': Decimal('329.99'),
		'Discount': 0,
		'Manufacturer': 'Bunn',
		'Cost': Decimal('234'),
		'Image': 'BE0029.jpg',
		'Description': '<p>The BUNN 12-Cup Pourover Commercial Coffee Brewer with Two Warmers, Upper and Lower and Two Glass Decanters in Black is an integral part of any office coffee service program. Totally portable, the brewer can be used anywhere there\'s a plug! Just pour cold water in the top and coffee brews immediately, up to 3.8 gallons per hour directly into the included standard 12-cup (64-ounce) decanters. It\'s attractive, black finish allows for quick and easy clean up and the SplashGuard funnel protects the user from burns. Includes two Easy Pour glass decanters.</p>',
		'Taxable': True,
		'Weight': Decimal('25'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Brewing Equipment","Coffee Brewers"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'BE0030',
		'ProductName': 'Fetco Hot Water Dispenser: 5 Gallon',
		'Price': Decimal('995'),
		'Discount': 0,
		'Manufacturer': 'Fetco',
		'Cost': Decimal('710'),
		'Image': 'BE0030.jpg',
		'Description': '<p>The 5-gallon hot water dispenser is the ideal size for medium-to-heavy duty food/beverage prep and cleaning tasks and combines the simplicity of a traditional style pull faucet with the modern convenience of a touchscreen interface. The dynamic touchscreen display allows for easy access to temperature controls, dispense metrics and diagnostics while the simple screen layout makes it easy for staff to understand and operate. The simple and intuitive screen design makes it easy to program the desired temperature for consistent and precise hot water dispensing for a variety of foods such as gravy, oatmeal, mashed potatoes, cheese sauce, gelatins & much more.</p>',
		'Taxable': True,
		'Weight': Decimal('44'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Brewing Equipment","Hot Water Dispensers"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'BE0031',
		'ProductName': 'Brood Nitro Beverage Dispenser',
		'Price': Decimal('3300'),
		'Discount': 0,
		'Manufacturer': 'Brood',
		'Cost': Decimal('2355'),
		'Image': 'BE0031.jpg',
		'Description': '<p>Nitro brew coffee has never been easier with the Nitro V2PX series from Brood. This system draws cold brew coffee from any container, keg, or bag-in-a-box, chills it and infuses the coffee with nitrogen. This nitrogen has been extracted from the air, meaning that no nitrogen tanks are required. Unlike traditional Nitro Kegerators, the Nitro V2PX is compact, portable, and easy to transport. As it does not rely on a supply on nitrogen via a tank, the N2PX produces unlimited nitro coffee for as long as you need it (or until your coffee supply is depleted), without the hassle of replacing tanks or monitoring pressure regulators. With the Nitro V2PX series systems, you can pour a drink of nitro coffee in less than 7 seconds with complete consistency and with the creamy, smooth mouthfeel that you love from nitro-infused beverages. Expand your coffee menu with the V2PX machine and experience the on-demand, low-wastage convenience of nitro coffee.</p>',
		'Taxable': True,
		'Weight': Decimal('37'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Brewing Equipment","Nitro Equipment"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'BE0032',
		'ProductName': 'Toddy, Cold Brew Commercial Model',
		'Price': Decimal('179'),
		'Discount': 0,
		'Manufacturer': 'Toddy & The Beverage Gourmet',
		'Cost': Decimal('127'),
		'Image': 'BE0032.jpg',
		'Description': '<p>This cold water brewing method extracts less oils than hot brew methods and with 2/3 less acid you get a smoother cup of coffee that\'s easier on the stomach. Use the Toddy concentrate in hot or cold drinks.</p>',
		'Taxable': True,
		'Weight': Decimal('26'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Brewing Equipment","Cold Brewers"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'BE0033',
		'ProductName': 'TableCraft 2.5 Gallon Drink Dispenser',
		'Price': Decimal('124.99'),
		'Discount': 0,
		'Manufacturer': 'Tablecraft',
		'Cost': Decimal('89'),
		'Image': 'BE0033.jpg',
		'Description': '<p>TableCraft Double Wall Stainless Steel Beverage Dispenser will certainly become a party-throwing must. Its removable Infuser and Ice Core make easy and fast delicious drinks. This Beverage Dispenser will keep things tasting fresh. It\'s Clear Stainless Steel design with unbreakable BPA-free plastic is perfect for indoor and outdoor use. Hand washing is recommended for keeping this item ready on its toes.</p>',
		'Taxable': True,
		'Weight': Decimal('10.6'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Brewing Equipment","Beverage Dispensers"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'BE0034',
		'ProductName': 'Fellow, Raven Stovetop Kettle + Tea Steeper, Matte Black',
		'Price': Decimal('79.99'),
		'Discount': 0,
		'Manufacturer': 'Fellow',
		'Cost': Decimal('57'),
		'Image': 'BE0034.jpg',
		'Description': '<p>Raven stovetop kettle and tea steeper makes steeping any type of tea easy with its brew-range thermometer, weighted handle, and integrated tea filter. Heat and steep your tea in the same vessel, saving time and cleanup. Steep at the perfect temperature for green/white teas, oolongs and black teas using the color guide on your brew-range thermometer. Raven\'s contemporary yet classic design takes familiar shapes, like the iconic pointed tea spout and mixes it with Fellow\'s modern design style.</p>',
		'Taxable': True,
		'Weight': Decimal('2.2'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Brewing Equipment","Coffee Brewers"]'
	}
)

response = table.put_item(
	Item={
		'ProductId': 'BE0035',
		'ProductName': 'Yama Silverton Hot or Cold Coffee Dripper',
		'Price': Decimal('129.99'),
		'Discount': 0,
		'Manufacturer': 'Yama Glass',
		'Cost': Decimal('92'),
		'Image': 'BE0035.jpg',
		'Description': '<p>This Yama Glass Silverton Brewer is an awesome multi-purpose brewer. Perfect for brewing pour-overs, cold brew coffee, or tea, the Silverton Brewer is a must-have tool for any coffee or tea enthusiast. Each Yama Glass Silverton Brewer is made with heat resistant, hand blown borosilicate glass, and comes with a stainless steel filter cone. The bottom beaker holds 473ml, or 16oz, making enough coffee, cold brew, or tea for you and a friend. Fits Kalita 185 Filters.</p>',
		'Taxable': True,
		'Weight': Decimal('3.5'),
		'Unit': 'each',
		'Count': 1,
		'Categories': '["Brewing Equipment","Coffee Brewers"]'
	}
)

print("Records successfully loaded!")
