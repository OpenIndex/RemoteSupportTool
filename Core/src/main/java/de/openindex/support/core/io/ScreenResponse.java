/*
 * Copyright 2015-2019 OpenIndex.de.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package de.openindex.support.core.io;

import java.io.Serializable;

/**
 * Response with a screenshot.
 *
 * @author Andreas Rudolph
 */
public class ScreenResponse implements Serializable {
    private static final long serialVersionUID = 1;
    public final ScreenTile[] tiles;
    public final int screenWidth;
    public final int screenHeight;
    public final int imageWidth;
    public final int imageHeight;
    public final int tileWidth;
    public final int tileHeight;

    public ScreenResponse() {
        this(null, 0, 0, 0, 0, 0, 0);
    }

    public ScreenResponse(ScreenTile[] tiles, int screenWidth, int screenHeight, int imageWidth, int imageHeight, int tileWidth, int tileHeight) {
        super();
        this.tiles = tiles;
        this.screenWidth = screenWidth;
        this.screenHeight = screenHeight;
        this.imageWidth = imageWidth;
        this.imageHeight = imageHeight;
        this.tileWidth = tileWidth;
        this.tileHeight = tileHeight;
    }
}
