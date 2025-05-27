import requests
import os
import jsontolua
from urllib.parse import quote_plus 

base_url = 'https://murlok.io/api/guides'
contents = ['mm+', 'solo']

classes = {        
        'death-knight': {
            'blood': ['san\'layn', 'deathbringer'],
            'frost': ['rider-of-the-apocalypse', 'deathbringer'],
            'unholy': ['san\'layn', 'rider-of-the-apocalypse']
        },

        'demon-hunter': {
            'havoc': ['fel-scarred', 'aldrachi-reaver'],
            'vengeance': ['fel-scarred', 'aldrachi-reaver']
        },

        'druid': {
            'balance': ['keeper-of-the-grove', 'elune\'s-chosen'],
            'feral': ['druid-of-the-claw', 'wildstalker'],
            'guardian': ['druid-of-the-claw', 'elune\'s-chosen'],
            'restoration': ['wildstalker', 'keeper-of-the-grove']
        },

        'evoker': {
            'devastation': ['scalecommander', 'flameshaper'],
            'preservation': ['flameshaper', 'chronowarden'],
            'augmentation': ['scalecommander', 'chronowarden']
        },

        'hunter': {
            'beast-mastery': ['pack-leader', 'dark-ranger'],
            'marksmanship': ['sentinel', 'dark-ranger'],
            'survival': ['sentinel', 'pack-leader']
        },

        'mage': {
            'arcane': ['sunfury', 'spellslinger'],
            'fire': ['sunfury', 'frostfire'],
            'frost': ['spellslinger', 'frostfire']
        },

        'monk': {
            'brewmaster': ['shado-pan', 'master-of-harmony'],
            'windwalker': ['conduit-of-the-celestials', 'shado-pan'],
            'mistweaver': ['conduit-of-the-celestials', 'master-of-harmony'],
        },

        'paladin': {
            'holy': ['lightsmith', 'herald-of-the-sun'],
            'protection': ['templar', 'lightsmith'],
            'retribution': ['templar', 'herald-of-the-sun'],
        },

        'priest': {
            'discipline': ['voidweaver', 'oracle'],
            'holy': ['archon', 'oracle'],
            'shadow': ['voidweaver', 'archon'],
        },

        'rogue': {
            'assassination': ['fatebound', 'deathstalker'],
            'outlaw': ['trickster', 'fatebound'],
            'subtlety': ['trickster', 'deathstalker'],
        },

        'shaman': {
            'elemental': ['stormbringer', 'farseer'],
            'enhancement': ['totemic', 'stormbringer'],
            'restoration': ['totemic', 'farseer'],
        },

        'warlock': {
            'affliction': ['soul-harvester', 'hellcaller'],
            'demonology': ['soul-harvester', 'diabolist'],
            'destruction': ['hellcaller', 'diabolist'],
        },

        'warrior': {
            'arms': ['slayer', 'colossus'],
            'fury': ['slayer', 'mountain-thane'],
            'protection': ['mountain-thane', 'colossus']
        }

        # '': {
        #     '': ['', ''],
        #     '': ['', ''],
        #     '': ['', ''],
        # },
    }

oauth_res = requests.post('https://oauth.battle.net/token', data={'grant_type': 'client_credentials'}, auth=(os.environ["BNET_CLIENT_ID"], os.environ["BNET_CLIENT_SECRET"]))
if oauth_res.status_code != 200:
    raise Exception('Token for BNET couldn\'t be fetched')
bnet_token = oauth_res.json()['access_token']

exports = {}
for content in contents:
    export = {}
    exports[content] = export
    for cls, config in classes.items():
        if cls not in ['paladin'] or content not in ['mm+']:
            continue
        export[cls] = {}
        for spec, heros in config.items():
            export[cls][spec] = {}
            for hero in heros:

                response = requests.get(f'{base_url}/{cls}/{spec}/{hero}/{content}')
                if response.status_code != 200:
                    continue

                chars = response.json()['Characters']
                nchars = len(chars)

                stats = {
                    'count': 0,
                    'secondary_stats': {
                        'haste': {'percent': 0, 'value': 0},
                        'crit': {'percent': 0, 'value': 0},
                        'mastery': {'percent': 0, 'value': 0},
                        'versatility': {'percent': 0, 'value': 0}
                    },
                    'minor_stats': {                
                        'leech': {'percent': 0, 'value': 0},
                        'speed': {'percent': 0, 'value': 0},
                        'avoidance': {'percent': 0, 'value': 0}
                    },
                    'talents': [],
                    'traits': {
                        'class': {},
                        'spec': {},
                        'hero': {},
                        'pvp': {}
                    }
                }

                equips = {}
                for i, char in enumerate(chars):                
                    stats['secondary_stats']['haste']['percent'] += char.get('HasteValue', 0)
                    stats['secondary_stats']['crit']['percent'] += char.get('CritValue', 0)
                    stats['secondary_stats']['mastery']['percent'] += char.get('MasteryValue', 0)
                    stats['secondary_stats']['versatility']['percent'] += char.get('VersatilityATK', 0)
                    stats['minor_stats']['leech']['percent'] += char.get('LeechValue', 0)
                    stats['minor_stats']['speed']['percent'] += char.get('SpeedValue', 0)
                    stats['minor_stats']['avoidance']['percent'] += char.get('AvoidanceValue', 0)

                    stats['secondary_stats']['haste']['value'] += char.get('Haste', 0)
                    stats['secondary_stats']['crit']['value'] += char.get('Crit', 0)
                    stats['secondary_stats']['mastery']['value'] += char.get('Mastery', 0)
                    stats['secondary_stats']['versatility']['value'] += char.get('Versatility', 0)
                    stats['minor_stats']['leech']['value'] += char.get('Leech', 0)
                    stats['minor_stats']['speed']['value'] += char.get('Speed', 0)
                    stats['minor_stats']['avoidance']['value'] += char.get('Avoidance', 0)

                    stats['count'] += 1
                    if i == 0:
                        stats['rating'] = char.get('RatingMM') if content == 'mm+' else char.get('RatingSoloShuffle')

                    if len(stats['talents']) < 5:
                        stats['talents'].append(char['TalentsCode'])

                    if 'Items' in char['Equipment']:
                        for item in char['Equipment']['Items']:
                            id = item['ItemID']
                            if id > 0:
                                slot = item['Slot']
                                if slot not in equips:
                                    equips[slot] = {'items': {}, 'gems': {}, 'enchantments': {}}
                                
                                if id not in equips[slot]['items']:
                                    equips[slot]['items'][id] = {'count': 0, 'rank': i}
                                    equips[slot]['items'][id]['charAPI'] = f'https://{char["Region"]}.api.blizzard.com/profile/wow/character/{quote_plus(char["RealmSlug"])}/{quote_plus(char["Slug"])}/equipment?namespace=profile-{char["Region"]}&locale=en_US'

                                equips[slot]['items'][id]['count'] += 1

                                if 'Gems' in item:
                                    for gem in item['Gems']:
                                        id = gem['ItemID']
                                        if id > 0:
                                            if id not in equips[slot]['gems']:
                                                equips[slot]['gems'][id] = {'count': 0, 'rank': i}
                                            equips[slot]['gems'][id]['count'] += 1

                                if 'Enchantments' in item:
                                    for enchantment in item['Enchantments']:
                                        id = enchantment['ID']
                                        if id > 0:
                                            if id not in equips[slot]['enchantments']:
                                                equips[slot]['enchantments'][id] = {'count': 0, 'rank': i}
                                            equips[slot]['enchantments'][id]['count'] += 1
                                            
                    for trait in char['ClassTalents']:
                        if trait['ID'] > 0:
                            if trait['ID'] not in stats['traits']['class']:
                                stats['traits']['class'][trait['ID']] = {'count': 0, 'rank': i}
                            stats['traits']['class'][trait['ID']]['count'] += 1

                    for trait in char['SpecializationTalents']:
                        if trait['ID'] > 0:
                            if trait['ID'] not in stats['traits']['spec']:
                                stats['traits']['spec'][trait['ID']] = {'count': 0, 'rank': i}
                            stats['traits']['spec'][trait['ID']]['count'] += 1

                    for trait in char['HeroTalents']:
                        if trait['ID'] > 0:
                            if trait['ID'] not in stats['traits']['hero']:
                                stats['traits']['hero'][trait['ID']] = {'count': 0, 'rank': i}
                            stats['traits']['hero'][trait['ID']]['count'] += 1                        

                    if 'PvPTalents' in char:
                        for trait in char['PvPTalents']:
                            if trait['ID'] > 0:
                                if trait['ID'] not in stats['traits']['pvp']:
                                    stats['traits']['pvp'][trait['ID']] = {'count': 0, 'rank': i}
                                stats['traits']['pvp'][trait['ID']]['count'] += 1                                   

                if stats['count'] > 0:
                    stats['secondary_stats']['haste']['percent'] = round(stats['secondary_stats']['haste']['percent']/stats['count'])
                    stats['secondary_stats']['crit']['percent'] = round(stats['secondary_stats']['crit']['percent']/stats['count'])
                    stats['secondary_stats']['mastery']['percent'] = round(stats['secondary_stats']['mastery']['percent']/stats['count'])
                    stats['secondary_stats']['versatility']['percent'] = round(stats['secondary_stats']['versatility']['percent']/stats['count'])
                    stats['minor_stats']['leech']['percent'] = round(stats['minor_stats']['leech']['percent']/stats['count'])
                    stats['minor_stats']['speed']['percent'] = round(stats['minor_stats']['speed']['percent']/stats['count'])
                    stats['minor_stats']['avoidance']['percent'] = round(stats['minor_stats']['avoidance']['percent']/stats['count'])

                    stats['secondary_stats']['haste']['value'] = round(stats['secondary_stats']['haste']['value']/stats['count'])
                    stats['secondary_stats']['crit']['value'] = round(stats['secondary_stats']['crit']['value']/stats['count'])
                    stats['secondary_stats']['mastery']['value'] = round(stats['secondary_stats']['mastery']['value']/stats['count'])
                    stats['secondary_stats']['versatility']['value'] = round(stats['secondary_stats']['versatility']['value']/stats['count'])
                    stats['minor_stats']['leech']['value'] = round(stats['minor_stats']['leech']['value']/stats['count'])
                    stats['minor_stats']['speed']['value'] = round(stats['minor_stats']['speed']['value']/stats['count'])
                    stats['minor_stats']['avoidance']['value'] = round(stats['minor_stats']['avoidance']['value']/stats['count'])

                stats['secondary_stats'] = {key: value for key, value in sorted(stats['secondary_stats'].items(), key=lambda item: item[1]['value'], reverse=True)}
                stats['minor_stats'] = {key: value for key, value in sorted(stats['minor_stats'].items(), key=lambda item: item[1]['value'], reverse=True)}
                order = 0
                for slot, equip in equips.items():
                    for att, counts in equip.items():
                        equips[slot][att] = {key: value for key, value in sorted(counts.items(), key=lambda item: item[1]['count'], reverse=True)[:5:]}
                
                    equip["order"] = order
                    order += 1

                bnet_chars = {}
                for slot, equip in equips.items():
                    for item_id, counts in equip['items'].items():
                        charAPI = counts['charAPI']
                        print(content, cls, spec, hero, slot, item_id, charAPI)
                        if charAPI not in bnet_chars:
                            response = requests.get(counts['charAPI'], headers={'Authorization': f'Bearer {bnet_token}'})
                            if response.status_code == 200:
                                bnet_chars[charAPI] = response.json()['equipped_items']
                            else:
                                print(response.status_code, slot, item_id, charAPI)
                        
                        if charAPI in bnet_chars:
                            bnet_items = bnet_chars[charAPI]
                            for bnet_item in bnet_items:
                                if bnet_item['slot']['name'].lower() == slot.replace('-', ' ') and 'bonus_list' in bnet_item:
                                    counts['bonus'] = bnet_item['bonus_list']

                stats['equips'] = equips
                export[cls][spec][hero] = stats

with open('export.lua', 'w') as file:
    lua_export = ''.join(jsontolua.dic_to_lua_str(exports))
    file.writelines(f'MurlokExport = {lua_export}')
  
