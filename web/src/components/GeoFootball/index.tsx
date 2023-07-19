import type { Station, GroupedStations } from './types'
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet'
import { Icon } from 'leaflet'
import MarkerClusterGroup from 'react-leaflet-cluster'
import Image from 'next/image'
import { useState } from 'react'
import { Noto_Color_Emoji } from 'next/font/google'

import MapForm from './form'
import { deleteStation, flag } from './slice'

import styles from './index.module.css'


const emoji = Noto_Color_Emoji({ weight: '400', subsets: ['emoji'], preload: false })

interface Properties {
	stationsByCountry: GroupedStations,
}

const train = new Icon({
	iconUrl: 'https://cdn-icons-png.flaticon.com/512/1702/1702305.png',
	iconSize: [24, 24],
	iconAnchor: [12, 12],
})

const GeoFootball = ({ stationsByCountry }: Properties) => {
	const openStreetMaps = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
	const copyright = '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'

	const [clusters, setClusters] = useState(stationsByCountry)

	const remove = async (station: Station, index: number) => {
		const response = await deleteStation(station.id)
		if (response.ok) {
			const cluster = clusters[station.country]
			cluster.splice(index, 1)
			setClusters({
				...clusters,
				[station.country]: [...cluster],
			})
		}
	}

	return (
		<MapContainer className={styles.map} center={[51.505, 0]} zoom={5} scrollWheelZoom doubleClickZoom={false}>
			<TileLayer attribution={copyright} url={openStreetMaps} />
			<MapForm clusters={clusters} setClusters={setClusters} />
			{Object.entries(clusters).map(([country, stations]) =>
				<MarkerClusterGroup key={country} chunkedLoading>
					{(stations as Station[]).map((station: Station, index: number) =>
						<Marker key={`train-${station.id}`} position={[station.latitude, station.longitude]} icon={train}>
							<Popup key={`train-popup-${station.id}`}>
								<div className={styles.popup}>
									<h3>{station.name}</h3>
									<dl>
										<dt>Country: </dt><dd>{country} <span className={emoji.className}>{flag(country)}</span></dd>
										<dt>Position: </dt><dd>{station.latitude.toFixed(5)}, {station.longitude.toFixed(5)}</dd>
										<dt>Timezone: </dt><dd>{station.time_zone}</dd>
									</dl>
									<p>{station.info_en}</p>
									<button className={styles.delete} onClick={() => remove(station, index)}>
										<Image src="https://cdn-icons-png.flaticon.com/512/6711/6711573.png" width={16} height={16} alt="Delete" />
										Delete
									</button>
								</div>
							</Popup>
						</Marker>
					)}
				</MarkerClusterGroup>
			)}

		</MapContainer>
	)
}

export default GeoFootball
