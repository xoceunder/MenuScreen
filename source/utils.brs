' Helper function convert AA to Node
function ContentListToSimpleNode(contentList as Object, nodeType = "ContentNode" as String) as Object
    result = CreateObject("roSGNode", nodeType) ' create node instance based on specified nodeType
    if result <> invalid
        ' go through contentList and create node instance for each item of list
        for each itemAA in contentList
            item = CreateObject("roSGNode", nodeType)
            item.SetFields(itemAA)
            result.AppendChild(item) 
        end for
    end if
    return result
end function

' Helper function convert seconds to mm:ss format
' getTime(138) returns 2:18
function GetTime(length as Integer) as String
    minutes = (length \ 60).ToStr()
    seconds = length MOD 60
    if seconds < 10
       seconds = "0" + seconds.ToStr()
    else
       seconds = seconds.ToStr()
    end if
    return minutes + ":" + seconds
end function

function CloneChildren(node as Object, startItem = 0 as Integer)
    numOfChildren = node.GetChildCount() ' get number of row items
    ' populate children array only with  items started from selected one.
    ' example: row has 3 items. user select second one so we must take just second and third items.
    children = node.GetChildren(numOfChildren - startItem, startItem)
    childrenClone = []
    ' go through each item of children array and clone them.
    for each child in children
    ' we need to clone item node because it will be damaged in case of video node content invalidation
        childrenClone.Push(child.Clone(false))
    end for
    return childrenClone
end function

REM ******************************************************
REM Constucts a URL Transfer object
REM ******************************************************
Function CreateURLTransferObject(url As String, contentHeader="application/x-www-form-urlencoded" As String) as Object
  obj = CreateObject("roUrlTransfer")
  obj.SetPort(CreateObject("roMessagePort"))
  obj.SetUrl(url)
  obj.EnableEncodings(true)
  obj.AddHeader("Content-Type", contentHeader)
  if m.global.user <> invalid and m.global.user.isLoggedIn then obj.AddHeader("X-Auth-Token", m.global.user.token)
  if LCase(Left(url,8)) = "https://"
    obj.SetCertificatesFile("common:/certs/ca-bundle.crt")
    obj.AddHeader("X-Roku-Reserved-Dev-Id", "")
    obj.InitClientCertificates()
  end if
  return obj
End Function


REM ******************************************************
REM Url Query builder
REM ******************************************************
Function NewHttp(url As String, contentHeader="application/json" As String) as Object
  obj = CreateObject("roAssociativeArray")
  obj.contentHeader               = contentHeader
  obj.Http                        = CreateURLTransferObject(url, obj.contentHeader)
  obj.Method                      = "GET"
  obj.HTTP_TIMEOUT                = 60
  obj.useCookies                  = false
  obj.saveCookies                 = false
  obj.retainBodyOnError           = false
'  obj.FirstParam                  = true
  obj.Params                      = {}
  obj.AddParamsToRequest          = add_params_to_request
  obj.AddParam                    = http_add_param
'  obj.AddRawQuery                 = http_add_raw_query
  obj.GetToStringWithRetry        = http_get_to_string_with_retry
'  obj.PrepareUrlForQuery          = http_prepare_url_for_query
  obj.GetToStringWithTimeout      = http_get_to_string_with_timeout
  obj.PostFromStringWithTimeout   = http_post_from_string_with_timeout
  obj.HandleRawResponse           = function(event as Object) as String
                                      m.responseCode = event.GetResponseCode()
                                      m.isSuccess = (m.responseCode >= 200 and m.responseCode < 300)
                                      return event.GetString()
                                    end function

  obj.Request                     = function()
                                      m.Http.RetainBodyOnError(m.retainBodyOnError)
                                      m.AddParamsToRequest()
                                      if m.useCookies
                                        cookie = restoreCookies()
                                        if cookie <> invalid then m.Http.AddHeader("Cookie", cookie)
                                      end if
                                      if m.Method = "GET"
                                        return m.GetToStringWithTimeout(m.HTTP_TIMEOUT)
                                      else
                                        m.Http.setRequest(UCase(m.Method))
                                        return m.PostFromStringWithTimeout(m.body, m.HTTP_TIMEOUT)
                                      end if
                                      return invalid
                                    end function

'  if Instr(1, url, "?") > 0 then obj.FirstParam = false

  return obj
End Function


REM ******************************************************
REM HttpEncode - just encode a string
REM ******************************************************
Function add_params_to_request()
  m.body = ""
  if isNonEmptyAA(m.Params)
    if m.Method = "GET" or (m.Method = "POST" and m.contentHeader = "application/x-www-form-urlencoded")
      bodyArray = []
      for each key in m.Params.keys()
        if isString(m.Params[key])
          bodyArray.push(key.Escape() + "=" + m.Params[key].Escape())
        else if isNumber(m.Params[key]) or isBoolean(m.Params[key])
          bodyArray.push(key.Escape() + "=" + m.Params[key].toStr().Escape())
        else if isArray(m.Params[key])
          for each item in m.Params[key]
'            m.AddParam(key, item)
            bodyArray.push(key.Escape() + "=" + evalString(item).Escape())
          end for
        end if
      end for
      m.body = bodyArray.join("&")
      if m.body <> "" and m.Method = "GET"
        url = m.Http.GetUrl()
        if url.Instr("?") > 0
          url += "&" + m.body
        else
          url += "?" + m.body
        end if
        m.Http.SetUrl(url)
      end if
'      if m.Method = "POST" then m.body = ""
    else if m.Method = "POST" and m.contentHeader = "application/json"
      m.body = FormatJson(m.Params)
    end if
  end if
End Function


REM ******************************************************
REM Prepare the current url for adding query parameters
REM Automatically add a '?' or '&' as necessary
REM ******************************************************
'Function http_prepare_url_for_query() As String
'  url = m.Http.GetUrl()
'  if url.Instr("?") < 0
'    url += "?"
''    m.FirstParam = false
'  else
'    url += "&"
'  endif
'  m.Http.SetUrl(url)
'  return url
'End Function


REM ******************************************************
REM Percent encode a name/value parameter pair and add the
REM the query portion of the current url
REM Automatically add a '?' or '&' as necessary
REM Prevent duplicate parameters
REM ******************************************************
Function http_add_param(name As String, val As String) as Void
  paramAA = {}
  paramAA[name] = val
  m.Params.Append(paramAA)
'  q = name.Escape() + "="
'  url = m.Http.GetUrl()
'  if Instr(1, url, q) > 0 return    'Parameter already present
'  q = q + m.Http.Escape(val)
'  m.AddRawQuery(q)
End Function


REM ******************************************************
REM Tack a raw query string onto the end of the current url
REM Automatically add a '?' or '&' as necessary
REM ******************************************************
'Function http_add_raw_query(query As String) as Void
'  m.Http.SetUrl(m.PrepareUrlForQuery() + query)
'End Function


REM ******************************************************
REM Performs Http.AsyncGetToString() in a retry loop
REM with exponential backoff. To the outside
REM world this appears as a synchronous API.
REM ******************************************************
Function http_get_to_string_with_retry() as String
  timeout%         = m.HTTP_TIMEOUT * 1000
  num_retries%     = 5

  str = ""
  while num_retries% > 0
    if (m.Http.AsyncGetToString())
      event = wait(timeout%, m.Http.GetPort())
      if type(event) = "roUrlEvent"
        str = m.HandleRawResponse(event)
        if m.saveCookies then saveCookies(getCookies(event))
        exit while        
      else if event = invalid
        m.Http.AsyncCancel()
        REM reset the connection on timeouts
        m.Http = CreateURLTransferObject(m.Http.GetUrl(), m.contentHeader)
        timeout% = 2 * timeout%
      else
        print "roUrlTransfer::AsyncGetToString(): unknown event"
      endif
    endif

    num_retries% = num_retries% - 1
  end while

  return str
End Function


REM ******************************************************
REM Performs Http.AsyncGetToString() with a single timeout in seconds
REM To the outside world this appears as a synchronous API.
REM ******************************************************
Function http_get_to_string_with_timeout(seconds as Integer) as String
  timeout% = 1000 * seconds

  str = ""
  m.Http.EnableFreshConnection(true) 'Don't reuse existing connections
  if (m.Http.AsyncGetToString())
    event = wait(timeout%, m.Http.GetPort())
    if type(event) = "roUrlEvent"
      str = m.HandleRawResponse(event)
      if m.saveCookies then saveCookies(getCookies(event))
    else if event = invalid
      Dbg("AsyncGetToString timeout")
      m.Http.AsyncCancel()
    else
      Dbg("AsyncGetToString unknown event", event)
    endif
  endif

  return str
End Function


REM ******************************************************
REM Performs Http.AsyncPostFromString() with a single timeout in seconds
REM To the outside world this appears as a synchronous API.
REM ******************************************************
Function http_post_from_string_with_timeout(val As String, seconds as Integer) as String
  timeout% = 1000 * seconds

  str = ""
'    m.Http.EnableFreshConnection(true) 'Don't reuse existing connections
  if (m.Http.AsyncPostFromString(val))
    event = wait(timeout%, m.Http.GetPort())
    if type(event) = "roUrlEvent"
      Dbg("roUrlEvent received")
      str = m.HandleRawResponse(event)
      if m.saveCookies then saveCookies(getCookies(event))
    else if event = invalid
      Dbg("AsyncPostFromString timeout")
      m.Http.AsyncCancel()
    else
      Dbg("AsyncPostFromString unknown event", event)
    endif
  endif

  return str
End Function

'return an array of cookies, from a response. These can be added to a roUrlTransfer using AddCookies()
'creating them as an roArray of roAssociativeArrays - as expected by AddCookies()
function getCookies(msg)
  cookies = []
  if type(msg)="roUrlEvent"

    'search for any Set-Cookie headers
    responseHeaders = msg.GetResponseHeadersArray()
    for each responseHeader in responseHeaders
      if responseHeader["Set-Cookie"] <> invalid

        'responseHeader["Set-Cookie"] will be a string of the format "CookieName=CookieValue; Version=1; Domain="... etc
        'key value pairs separated by ;
        'uses regex to split into substrings of "Key=Value"
        cookie = responseHeader["Set-Cookie"].split(";")[0].trim()

        cookies.Push(cookie)
      end if
    end for
  end if
  return cookies
end function


function restoreCookies() as Object
  cookies = restoreFile("tmp:/cookies/cookies")
  if cookies <> invalid then return cookies.join("; ")
  return invalid
end function


function saveCookies(cookies) as Object
  if not isInvalid(cookies) then saveFile("cookies/cookies", cookies)
end function


function clearCookies() as Object
  fileSystem = CreateObject("roFileSystem")
  fileSystem.CreateDirectory("tmp:/cookies")
  cookiesExists = fileSystem.Exists("tmp:/cookies/cookies")
  if cookiesExists then fileSystem.Delete("tmp:/cookies/cookies")
end function
