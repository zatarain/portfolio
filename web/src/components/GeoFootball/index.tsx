import type { Station } from './types'
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet'
import { Icon } from 'leaflet'
import MarkerClusterGroup from 'react-leaflet-cluster'
import styles from './index.module.css'
import { Noto_Color_Emoji } from 'next/font/google'

const emoji = Noto_Color_Emoji({ weight: '400', subsets: ['emoji'], preload: false })

interface Properties {
	stationsByCountry: any
}

function flag(country: string) {
	const points = country
		.toUpperCase()
		.split('')
		.map((char) => 127397 + char.charCodeAt(0));
	return String.fromCodePoint(...points);
}

const GeoFootball = ({ stationsByCountry }: Properties) => {
	const train = new Icon({
		iconUrl: 'https://cdn-icons-png.flaticon.com/512/1702/1702305.png',
		iconSize: [24, 24],
		iconAnchor: [12, 12],
	})

	const stadium = new Icon({
		iconUrl: 'https://cdn-icons-png.flaticon.com/512/1540/1540530.png',
		iconSize: [24, 24],
		iconAnchor: [12, 12],
	})

	return (
		<MapContainer className={styles.map} center={[51.505, 0]} zoom={5} scrollWheelZoom>
			<TileLayer
				attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
				url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
			/>
			{Object.entries(stationsByCountry).map(([country, stations]) =>
				<MarkerClusterGroup key={country} chunkedLoading>
					{(stations as Station[]).map((station: Station) =>
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
