/*
 * Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.wso2.is.data.sync.client.internal;

import org.wso2.is.data.sync.client.DefaultSyncClient;
import org.wso2.is.data.sync.client.SyncClient;
import org.wso2.is.data.sync.client.impl.oauth.OAuthV530V560SyncClient;
import org.wso2.is.data.sync.client.impl.oauth.OAuthV530V570SyncClient;

import java.util.ArrayList;
import java.util.List;

public class SyncClientHolder {

    private List<SyncClient> syncClients = new ArrayList<>();

    public SyncClientHolder() {

        syncClients.add(new OAuthV530V560SyncClient());
        syncClients.add(new OAuthV530V570SyncClient());
        syncClients.add(new DefaultSyncClient());
    }

    public List<SyncClient> getSyncClients() {

        return syncClients;
    }
}
