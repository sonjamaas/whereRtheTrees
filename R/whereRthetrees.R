#' A function to find the closest public nature area around you
#'
#' Being outside in nature is proven to be good for body and mind.
#' It can be calming, relaxing and grounding. It can make one happy and more level-headed.
#' So take a break, look for the closest public nature spot and go hug a tree!
#'
#' @param x A x coordinate as decimal degree.
#' @param y A y coordinate as decimal degree.
#' @param buffer The buffer radius around the position [m]. If too big,
#'     an error will occur because this package is using the demo-server of osrm
#'     which restricts the query size to 10000. Therefore, a buffer of 200-300m is
#'     often sufficient.
#' @param colorblind 1 or 0. If 1, a colorblind-friendly version of the
#'    plot will be shown.
#'
#' @returns A map of the nature areas around the given position, with a
#'     route pointing to the closest one.
#'
#' @examples
#' whereRthetrees(8.671087, 52.113866, 200, 1)
#' @export
whereRthetrees <- function(x,y,buffer, colorblind){                                         # whereRtheTrees function uses the x and y coordinates as well as the buffer area

  # get spatial variables
  aoi <- spatialExtent(x,y,buffer)                                              # get the aoi

  xylim <- xyLimits(x,y,buffer)                                                 # get the x and y limits
  xlim <- c(xylim[1],xylim[2])
  ylim <- c(xylim[3],xylim[4])

  pov <- getPOV(x,y)                                                            # get the pov

  # extract features from OSM
  streets <- extractStreets(aoi)                                                # extract the osm features for the specific aoi
  river <- extractRiver(aoi)
  forest <- extractForest(aoi)
  specialForest <- extractSpecialForest(aoi)
  wood <- extractWood(aoi)
  grassland <- extractGrassland(aoi)
  garden <- extractGarden(aoi)
  natureReserve <- extractNatureReserve(aoi)
  meadow <- extractMeadow(aoi)
  wine <- extractWine(aoi)
  singleTree <- extractSingleTree(aoi)
  treeLine <- extractTreeLine(aoi)
  park <- extractPark(aoi)

  closestNature <- findNature(streets, river, forest, specialForest, wood,      # find the closest nature point
                              singleTree, treeLine, grassland, meadow, park,
                              garden, natureReserve, pov)

  # calculate shortest route to nature point
  if (length(st_is_empty(closestNature))==0){
    stop("There is no public nature in the given area, sorry! Try a bigger area.",
         r"{

          /\_/\    Hrmpf.
         ( o.o )  /
          > ^ <
         /     \
         }")
  } else {
    # calculate the shortest route
    route <- osrmRoute(pov,closestNature, overview = "simplified")

    print("          /\\_/\\    Nature nearby!")
    print("         (  ♥.♥  )  /              ")
    print("          >  ˇ  <                  ")
    print("         / \\  / \\                ")
  }

  # plot the osm data
  if(colorblind == 1){
    plotFinal <- finalPlot2(streets, river, forest,                                # get the final plot
                           specialForest, wood, singleTree,
                           treeLine, grassland,
                           meadow, park, garden,
                           natureReserve, pov, xlim, ylim,closestNature, route)
  } else {
    plotFinal <- finalPlot(streets, river, forest,                                # get the final plot
                           specialForest, wood, singleTree,
                           treeLine, grassland,
                           meadow, park, garden,
                           natureReserve, pov, xlim, ylim,closestNature, route)
  }

  return(plotFinal)                                                             # function returns the final plot
}
