import json
import requests
import os
import json_to_lua
from urllib.parse import quote_plus 
from datetime import datetime
from datetime import timezone

base_url = 'https://murlok.io/api/guides'
contents = ['mm+', 'solo']

classes = {        
        'death-knight': {
            'blood': [{'id': 31, 'name': 'san\'layn'}, {'id': 33, 'name': 'deathbringer'}],
            'frost': [{'id': 32, 'name': 'rider-of-the-apocalypse'}, {'id': 33, 'name': 'deathbringer'}],
            'unholy': [{'id': 31, 'name': 'san\'layn'}, {'id': 32, 'name': 'rider-of-the-apocalypse'}]
        },

        'demon-hunter': {
            'havoc': [{'id': 34, 'name': 'fel-scarred'}, {'id': 35, 'name': 'aldrachi-reaver'}],
            'vengeance': [{'id': 34, 'name': 'fel-scarred'}, {'id': 35, 'name': 'aldrachi-reaver'}]
        },

        'druid': {
            'balance': [{'id': 23, 'name': 'keeper-of-the-grove'}, {'id': 24, 'name': 'elune\'s-chosen'}],
            'feral': [{'id': 21, 'name': 'druid-of-the-claw'}, {'id': 22, 'name': 'wildstalker'}],
            'guardian': [{'id': 21, 'name': 'druid-of-the-claw'}, {'id': 24, 'name': 'elune\'s-chosen'}],
            'restoration': [{'id': 22, 'name': 'wildstalker'}, {'id': 23, 'name': 'keeper-of-the-grove'}]
        },

        'evoker': {
            'devastation': [{'id': 36, 'name': 'scalecommander'}, {'id': 37, 'name': 'flameshaper'}],
            'preservation': [{'id': 37, 'name': 'flameshaper'}, {'id': 38, 'name': 'chronowarden'}],
            'augmentation': [{'id': 36, 'name': 'scalecommander'}, {'id': 38, 'name': 'chronowarden'}]
        },

        'hunter': {
            'beast-mastery': [{'id': 43, 'name': 'pack-leader'}, {'id': 44, 'name': 'dark-ranger'}],
            'marksmanship': [{'id': 42, 'name': 'sentinel'}, {'id': 44, 'name': 'dark-ranger'}],
            'survival': [{'id': 42, 'name': 'sentinel'}, {'id': 43, 'name': 'pack-leader'}]
        },

        'mage': {
            'arcane': [{'id': 39, 'name': 'sunfury'}, {'id': 40, 'name': 'spellslinger'}],
            'fire': [{'id': 39, 'name': 'sunfury'}, {'id': 41, 'name': 'frostfire'}],
            'frost': [{'id': 40, 'name': 'spellslinger'}, {'id': 41, 'name': 'frostfire'}]
        },

        'monk': {
            'brewmaster': [{'id': 65, 'name': 'shado-pan'}, {'id': 66, 'name': 'master-of-harmony'}],
            'windwalker': [{'id': 64, 'name': 'conduit-of-the-celestials'}, {'id': 65, 'name': 'shado-pan'}],
            'mistweaver': [{'id': 64, 'name': 'conduit-of-the-celestials'}, {'id': 66, 'name': 'master-of-harmony'}],
        },

        'paladin': {
            'holy': [{'id': 49, 'name': 'lightsmith'}, {'id': 50, 'name': 'herald-of-the-sun'}],
            'protection': [{'id': 48, 'name': 'templar'}, {'id': 49, 'name': 'lightsmith'}],
            'retribution': [{'id': 48, 'name': 'templar'}, {'id': 50, 'name': 'herald-of-the-sun'}],
        },

        'priest': {
            'discipline': [{'id': 18, 'name': 'voidweaver'}, {'id': 20, 'name': 'oracle'}],
            'holy': [{'id': 19, 'name': 'archon'}, {'id': 20, 'name': 'oracle'}],
            'shadow': [{'id': 18, 'name': 'voidweaver'}, {'id': 19, 'name': 'archon'}],
        },

        'rogue': {
            'assassination': [{'id': 52, 'name': 'fatebound'}, {'id': 53, 'name': 'deathstalker'}],
            'outlaw': [{'id': 51, 'name': 'trickster'}, {'id': 52, 'name': 'fatebound'}],
            'subtlety': [{'id': 51, 'name': 'trickster'}, {'id': 53, 'name': 'deathstalker'}],
        },

        'shaman': {
            'elemental': [{'id': 55, 'name': 'stormbringer'}, {'id': 56, 'name': 'farseer'}],
            'enhancement': [{'id': 54, 'name': 'totemic'}, {'id': 55, 'name': 'stormbringer'}],
            'restoration': [{'id': 54, 'name': 'totemic'}, {'id': 56, 'name': 'farseer'}],
        },

        'warlock': {
            'affliction': [{'id': 57, 'name': 'soul-harvester'}, {'id': 58, 'name': 'hellcaller'}],
            'demonology': [{'id': 57, 'name': 'soul-harvester'}, {'id': 59, 'name': 'diabolist'}],
            'destruction': [{'id': 58, 'name': 'hellcaller'}, {'id': 59, 'name': 'diabolist'}],
        },

        'warrior': {
            'arms': [{'id': 60, 'name': 'slayer'}, {'id': 62, 'name': 'colossus'}],
            'fury': [{'id': 60, 'name': 'slayer'}, {'id': 61, 'name': 'mountain-thane'}],
            'protection': [{'id': 61, 'name': 'mountain-thane'}, {'id': 62, 'name': 'colossus'}]
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

enchant_source = {
    3368: {'type': 'spell', 'id': 53344},
    3370: {'type': 'spell', 'id': 53343},
    3847: {'type': 'spell', 'id': 62158},
    5445: {'type': 'spell', 'id': 62158},
    6088: {'type': 'spell', 'id': 279183},
    6241: {'type': 'spell', 'id': 326805},
    6244: {'type': 'spell', 'id': 326977},
    6245: {'type': 'spell', 'id': 327082},
    6550: {'type': 'item', 'id': 200037},
    6571: {'type': 'item', 'id': 200031},
    6574: {'type': 'item', 'id': 200021},
    6580: {'type': 'item', 'id': 200022},
    6586: {'type': 'item', 'id': 200023},
    6591: {'type': 'item', 'id': 199989},
    6592: {'type': 'item', 'id': 200031},    
    6596: {'type': 'item', 'id': 199949},
    6598: {'type': 'item', 'id': 200033},
    6604: {'type': 'item', 'id': 200032},
    6605: {'type': 'item', 'id': 199934},
    6606: {'type': 'item', 'id': 199976},
    6607: {'type': 'item', 'id': 200018},
    6610: {'type': 'item', 'id': 200019},
    6612: {'type': 'item', 'id': 199978},
    6613: {'type': 'item', 'id': 200020},
    6614: {'type': 'item', 'id': 199943},
    6615: {'type': 'item', 'id': 199985},
    6616: {'type': 'item', 'id': 200027},
    6618: {'type': 'item', 'id': 199986},
    6619: {'type': 'item', 'id': 200028},
    6625: {'type': 'item', 'id': 200030},
    6631: {'type': 'item', 'id': 200050},
    6640: {'type': 'item', 'id': 200055},
    6642: {'type': 'item', 'id': 200012},
    6643: {'type': 'item', 'id': 200054},
    6654: {'type': 'item', 'id': 200058},
    6655: {'type': 'item', 'id': 200058},
    7331: {'type': 'item', 'id': 223659},
    7333: {'type': 'item', 'id': 223661},
    7334: {'type': 'item', 'id': 223662},
    7335: {'type': 'item', 'id': 225652},
    7336: {'type': 'item', 'id': 223664},
    7337: {'type': 'item', 'id': 223665},
    7338: {'type': 'item', 'id': 223672},
    7339: {'type': 'item', 'id': 223673},
    7340: {'type': 'item', 'id': 223674},
    7341: {'type': 'item', 'id': 223666},
    7343: {'type': 'item', 'id': 223668},
    7345: {'type': 'item', 'id': 223676},
    7346: {'type': 'item', 'id': 223677},
    7348: {'type': 'item', 'id': 128544},
    7349: {'type': 'item', 'id': 223671},
    7350: {'type': 'item', 'id': 223678},
    7351: {'type': 'item', 'id': 223679},
    7352: {'type': 'item', 'id': 223680},
    7354: {'type': 'item', 'id': 223682},
    7355: {'type': 'item', 'id': 223683},
    7356: {'type': 'item', 'id': 223684},
    7357: {'type': 'item', 'id': 223685},
    7358: {'type': 'item', 'id': 223686},
    7360: {'type': 'item', 'id': 223688},
    7361: {'type': 'item', 'id': 223689},
    7362: {'type': 'item', 'id': 223690},
    7363: {'type': 'item', 'id': 223691},
    7364: {'type': 'item', 'id': 223692},
    7380: {'type': 'item', 'id': 223708},
    7381: {'type': 'item', 'id': 223709},
    7382: {'type': 'item', 'id': 223710},
    7383: {'type': 'item', 'id': 223711},
    7384: {'type': 'item', 'id': 223712},
    7385: {'type': 'item', 'id': 223713},
    7386: {'type': 'item', 'id': 223714},
    7388: {'type': 'item', 'id': 223716},
    7390: {'type': 'item', 'id': 223718},
    7391: {'type': 'item', 'id': 223719},
    7392: {'type': 'item', 'id': 223720},
    7393: {'type': 'item', 'id': 223721},
    7394: {'type': 'item', 'id': 223722},
    7395: {'type': 'item', 'id': 223723},
    7396: {'type': 'item', 'id': 223724},
    7397: {'type': 'item', 'id': 223725},
    7400: {'type': 'item', 'id': 223728},
    7401: {'type': 'item', 'id': 223729},
    7402: {'type': 'item', 'id': 223730},
    7403: {'type': 'item', 'id': 223731},
    7404: {'type': 'item', 'id': 223732},
    7405: {'type': 'item', 'id': 223733},
    7406: {'type': 'item', 'id': 223734},
    7407: {'type': 'item', 'id': 223735},
    7408: {'type': 'item', 'id': 223736},
    7409: {'type': 'item', 'id': 223737},
    7410: {'type': 'item', 'id': 223738},
    7411: {'type': 'item', 'id': 223739},
    7412: {'type': 'item', 'id': 223740},
    7413: {'type': 'item', 'id': 223798},
    7414: {'type': 'item', 'id': 223799},
    7415: {'type': 'item', 'id': 223800},
    7416: {'type': 'item', 'id': 223651},
    7417: {'type': 'item', 'id': 223652},
    7418: {'type': 'item', 'id': 223653},
    7419: {'type': 'item', 'id': 223618},
    7420: {'type': 'item', 'id': 223649},
    7421: {'type': 'item', 'id': 223650},
    7422: {'type': 'item', 'id': 223654},
    7423: {'type': 'item', 'id': 223655},
    7424: {'type': 'item', 'id': 223656},
    7437: {'type': 'item', 'id': 223757},
    7438: {'type': 'item', 'id': 223758},
    7439: {'type': 'item', 'id': 223759},
    7440: {'type': 'item', 'id': 223760},
    7441: {'type': 'item', 'id': 223761},
    7442: {'type': 'item', 'id': 223762},
    7443: {'type': 'item', 'id': 223763},
    7444: {'type': 'item', 'id': 223764},
    7445: {'type': 'item', 'id': 223765},
    7446: {'type': 'item', 'id': 223766},
    7447: {'type': 'item', 'id': 223767},
    7448: {'type': 'item', 'id': 223768},
    7450: {'type': 'item', 'id': 223774},
    7451: {'type': 'item', 'id': 223775},
    7452: {'type': 'item', 'id': 223776},
    7453: {'type': 'item', 'id': 223777},
    7454: {'type': 'item', 'id': 223778},
    7455: {'type': 'item', 'id': 223770},
    7456: {'type': 'item', 'id': 223771},
    7457: {'type': 'item', 'id': 223772},
    7459: {'type': 'item', 'id': 223783},
    7460: {'type': 'item', 'id': 223784},
    7461: {'type': 'item', 'id': 223779},
    7462: {'type': 'item', 'id': 223780},
    7463: {'type': 'item', 'id': 223781},
    7469: {'type': 'item', 'id': 223786},
    7470: {'type': 'item', 'id': 223787},
    7472: {'type': 'item', 'id': 223789},
    7473: {'type': 'item', 'id': 223790},
    7474: {'type': 'item', 'id': 223794},
    7475: {'type': 'item', 'id': 223795},
    7476: {'type': 'item', 'id': 223796},
    7478: {'type': 'item', 'id': 223792},
    7479: {'type': 'item', 'id': 223793},
    7531: {'type': 'item', 'id': 222896},
    7931: {'type': 'item', 'id': 239093},
}
missing_enchants = {}
exports = {}
for content in contents:
    export = {}
    exports[content] = export
    for cls, config in classes.items():
        # if cls not in ['paladin'] or content not in ['mm+']:
        #     continue

        export[cls] = {}
        for spec, heros in config.items():
            export[cls][spec] = {}
            for hero in heros:
                hero_name = hero['name']

                # if cls not in ['druid'] or content not in ['mm+'] or spec not in ['guardian'] or hero_name not in ['elune\'s-chosen']:
                #     continue        

                response = requests.get(f'{base_url}/{cls}/{spec}/{hero_name}/{content}')
                if response.status_code != 200:
                    continue

                chars = response.json()['Characters']
                nchars = len(chars)

                stats = {
                    'id': hero['id'],
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

                    if len(stats['talents']) < 5 and 'TalentsCode' in char:
                        stats['talents'].append(char['TalentsCode'])

                    if 'Items' in char['Equipment']:
                        for item in char['Equipment']['Items']:
                            id = item['ItemID']
                            if id > 0 and ('RequiredLevel' not in item or item['RequiredLevel'] >= 80 ) and ('ILevel' not in item or item['ILevel'] >= 600):
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
                                                equips[slot]['enchantments'][id]['charAPI'] = f'https://{char["Region"]}.api.blizzard.com/profile/wow/character/{quote_plus(char["RealmSlug"])}/{quote_plus(char["Slug"])}/equipment?namespace=profile-{char["Region"]}&locale=en_US'
                                            equips[slot]['enchantments'][id]['count'] += 1

                    if 'ClassTalents' in char:              
                        for trait in char['ClassTalents']:
                            if trait['ID'] > 0:
                                if trait['ID'] not in stats['traits']['class']:
                                    stats['traits']['class'][trait['ID']] = {'count': 0, 'rank': i}
                                stats['traits']['class'][trait['ID']]['count'] += 1

                    if 'SpecializationTalents' in char:
                        for trait in char['SpecializationTalents']:
                            if trait['ID'] > 0:
                                if trait['ID'] not in stats['traits']['spec']:
                                    stats['traits']['spec'][trait['ID']] = {'count': 0, 'rank': i}
                                stats['traits']['spec'][trait['ID']]['count'] += 1

                    if 'HeroTalents' in char:
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
                def loadChar(charAPI):                    
                    # print(content, cls, spec, hero_name, slot, item_id, charAPI)
                    if charAPI not in bnet_chars:
                        response = requests.get(charAPI, headers={'Authorization': f'Bearer {bnet_token}'})
                        if response.status_code == 200:
                            body = response.json()
                            if 'equipped_items' in body:
                                bnet_chars[charAPI] = response.json()['equipped_items']
                            else:
                                print('missing items', response.status_code, slot, enchant_id, charAPI)
                                return False
                        else:
                            print(response.status_code, slot, enchant_id, charAPI)
                            return False
                    return True           

                for slot, equip in equips.items():
                    for enchant_id, counts in equip['items'].items():                        
                        if loadChar(counts['charAPI']):
                            bnet_items = bnet_chars[counts['charAPI']]
                            for bnet_item in bnet_items:
                                # if 'requirements' in bnet_item and bnet_item['requirements']['level']['value'] < 70:
                                #     del equip['items'][enchant_id]
                                if bnet_item['slot']['name'].lower() == slot.replace('-', ' ') and 'bonus_list' in bnet_item:
                                    counts['bonus'] = bnet_item['bonus_list']
                        del counts['charAPI']
                                        
                    for enchant_id, counts in equip['enchantments'].items():                        
                        if loadChar(counts['charAPI']):
                            bnet_items = bnet_chars[counts['charAPI']]
                            for bnet_item in bnet_items:
                                if bnet_item['slot']['name'].lower() == slot.replace('-', ' '):
                                    if 'enchantments' in bnet_item:
                                        for enchant in bnet_item['enchantments']:
                                            if enchant['enchantment_slot']['type'] == 'PERMANENT' and enchant['enchantment_id'] == enchant_id:
                                                if 'source_item' in enchant:
                                                    counts['source'] = {'type': 'item', 'id': enchant['source_item']['id']}
                                                elif enchant_id in enchant_source:
                                                    counts['source'] = enchant_source[enchant_id]
                                                elif enchant_id not in missing_enchants:
                                                    print('[Not found]', enchant_id, enchant['display_string'], counts['charAPI'])
                                                    missing_enchants[enchant_id] = enchant['display_string']
                                    elif enchant_id in enchant_source:
                                        counts['source'] = enchant_source[enchant_id]
                                    elif enchant_id not in missing_enchants:
                                        print('[Not found]', enchant_id, counts['charAPI'])
                                        missing_enchants[enchant_id] = [bnet_item['item']['id'],  counts['charAPI']]
                        del counts['charAPI']

                stats['equips'] = equips
                export[cls][spec][hero_name] = stats

with open('Python/Export.lua', 'w') as file:
    exports['timestamp'] = datetime.now(timezone.utc).isoformat()
    lua_export = ''.join(json_to_lua.dic_to_lua_str(exports, False))
    file.writelines(f'MurlokExport = {lua_export}')
  
with open('Python/MissingEnchants.lua', 'w') as file:
    file.writelines(''.join(json_to_lua.dic_to_lua_str({key: value for key, value in sorted(missing_enchants.items())})))
    