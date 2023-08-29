def lambda_handler(event, context):
    increase = '/increase'
    operetion = event['rawPath']

    if operetion == increase:
        rawQueryStringList = (event['rawQueryString']).split('=') 
        if rawQueryStringList[0] == 'i':
            try:
                number = int(rawQueryStringList[1])
                number += 1
                return number
            except ValueError:
                return 'Value should be integer, please provide correct value'
        else:
            return 'Key not permitted, please provide correct key'
    else:
        return 'Operation not permitted'
        