import type { Station } from './types'
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet'
import { Icon } from 'leaflet'
import MarkerClusterGroup from 'react-leaflet-cluster'
import styles from './index.module.css'

interface Properties {
	stationsByCountry: any
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
								<h3>{station.name}</h3>
								<dl className={styles.popup}>
									<dt>Country: </dt><dd>{country}</dd>
									<dt>Position: </dt><dd>{station.latitude}, {station.longitude}</dd>
									<dt>Time zone: </dt><dd>{station.time_zone}</dd>
								</dl>
								<p>{station.info_en}</p>
							</Popup>
						</Marker>
					)}
				</MarkerClusterGroup>
			)}

		</MapContainer>
	)
}

export default GeoFootball
