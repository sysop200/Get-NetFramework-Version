<#
        Reference   : https://msdn.microsoft.com/en-us/library/hh925568
#>
function Get-DotNetFrameworkVersion
{
    param(
        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    $dotNetRegistry  = 'SOFTWARE\Microsoft\NET Framework Setup\NDP'
    $dotNet4Registry = 'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'
    $dotNet4Builds = @{
        '50727'  = @{ Version = [System.Version]'2.0' ; Comment = '.Net Framework v2'                    }
        '30729'  = @{ Version = [System.Version]'3.0' ; Comment = '.Net Framework v3'                    }
        '30319'  = @{ Version = [System.Version]'4.0'                                                     }
        '378389' = @{ Version = [System.Version]'4.5'     ; Comment= 'Все версии операционной системы Windows'                                                }
        '378675' = @{ Version = [System.Version]'4.5.1'   ; Comment = 'Windows 8.1 и Windows Server 2012 R2'                      }
        '378758' = @{ Version = [System.Version]'4.5.1'   ; Comment = 'Все версии операционной системы Windows'               }
        '379893' = @{ Version = [System.Version]'4.5.2'   ; Comment = 'Все версии операционной системы Windows'                                                }
        '380042' = @{ Version = [System.Version]'4.5'     ; Comment = 'все версии операционной системы с KB3168275'   }
        '393295' = @{ Version = [System.Version]'4.6'     ; Comment = 'Windows 10'                      }
        '393297' = @{ Version = [System.Version]'4.6'     ; Comment = 'Все версии операционной системы Windows'                  }
        '394254' = @{ Version = [System.Version]'4.6.1'   ; Comment = 'Windows 10 с ноябрьскими обновлениями'                      }
        '394271' = @{ Version = [System.Version]'4.6.1'   ; Comment = 'Все версии операционной системы Windows'                  }
        '394802' = @{ Version = [System.Version]'4.6.2'   ; Comment = 'В юбилейном обновлении Windows 10 и Windows Server 2016'   }
        '394806' = @{ Version = [System.Version]'4.6.2'   ; Comment = 'Все версии операционной системы Windows'                  }
        '460798' = @{ Version = [System.Version]'4.7'     ; Comment = 'Windows 10 Обновление создателей'      }
        '460805' = @{ Version = [System.Version]'4.7'     ; Comment = 'Все версии операционной системы Windows'                  }
        '461308' = @{ Version = [System.Version]'4.7.1'   ; Comment = 'Windows 10 Обновление отстраненных разработчиков и Windows Server, версии 1709' }
        '461310' = @{ Version = [System.Version]'4.7.1'   ; Comment = 'Все версии операционной системы Windows'                  }
        '461808' = @{ Version = [System.Version]'4.7.0356'; Comment = 'Windows 10 апрельское обновление 2018 и Windows Server, версии 1803'                                              }
        '461814' = @{ Version = [System.Version]'4.7.0356'; Comment = 'On all Windows operating systems other than Windows 10 April 2018 Update and Windows Server, version 1803'}
        '528040' = @{ Version = [System.Version]'4.8'; Comment = 'On Windows 10 May 2019 Update and Windows 10 November 2019 Update'}
        '528372'= @{ Version = [System.Version]'4.8'; Comment = 'On Windows 10 May 2020 Update'}
        '528049' = @{ Version = [System.Version]'4.8'     ; Comment = 'Все остальные версии операционной системы Windows (включая другие операционные системы Windows 10)'}

    }

    foreach($computer in $ComputerName)
    {
        if($regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computer))
        {
            if ($netRegKey = $regKey.OpenSubKey("$dotNetRegistry"))
            {
                foreach ($versionKeyName in $netRegKey.GetSubKeyNames())
                {
                    if ($versionKeyName -match '^v[123]') {
                        $versionKey = $netRegKey.OpenSubKey($versionKeyName)
                        $version = [System.Version]($versionKey.GetValue('Version', ''))
                        New-Object -TypeName PSObject -Property ([ordered]@{
                                ComputerName = $computer
                                Build = $version.Build
                                Version = $version
                                Comment = $dotNet4Builds["$($version.Build)"].Comment
                        })
                    }
                }
            }

            if ($net4RegKey = $regKey.OpenSubKey("$dotNet4Registry"))
            {
                if(-not ($net4Release = $net4RegKey.GetValue('Release')))
                {

                    $net4Release = 30319
                }
                New-Object -TypeName PSObject -Property ([ordered]@{
                        ComputerName = $Computer
                        Build = $net4Release
                        Version = $net4RegKey.GetValue('Version')
                        Comment = $dotNet4Builds["$net4Release"].Comment
                })
            }
        }
    }
}
